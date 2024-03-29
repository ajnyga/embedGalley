<?php

/**
 * @file plugins/generic/embedGalley/EmbedGalleyPlugin.inc.php
 *
 * Copyright (c) 2014-2021 Simon Fraser University
 * Copyright (c) 2003-2021 John Willinsky
 * Copyright (c) 2017 The Federation of Finnish Learned Societies
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @class embedGalley
 * @ingroup plugins_generic_embedGalley
 *
 * @brief embedGalley plugin class
 */

import('lib.pkp.classes.plugins.GenericPlugin');

class EmbedGalleyPlugin extends GenericPlugin {
	/**
	 * Called as a plugin is registered to the registry
	 * @param $category String Name of category plugin was registered to
	 * @return boolean True iff plugin initialized successfully; if false,
	 * 	the plugin will not be registered.
	 */
	function register($category, $path, $mainContextId = NULL) {
		$success = parent::register($category, $path);
		if (!Config::getVar('general', 'installed') || defined('RUNNING_UPGRADE')) return true;
		if ($success && $this->getEnabled()) {
			// TODO: how do you define a sequence for all plugins using this hook?
			HookRegistry::register('Templates::Article::Footer::PageFooter', array($this, 'embedHtml'));
			// Add stylesheet and javascript
			HookRegistry::register('TemplateManager::display',array($this, 'displayCallback'));
		}
		return $success;
	}

	/**
	 * Get the plugin display name.
	 * @return string
	 */
	function getDisplayName() {
		return __('plugins.generic.embedGalley.displayName');
	}

	/**
	 * Get the plugin description.
	 * @return string
	 */
	function getDescription() {
		return __('plugins.generic.embedGalley.description');
	}


 	/**
	 * @copydoc Plugin::manage()
	 */
	function manage($args, $request) {
		switch ($request->getUserVar('verb')) {
			case 'settings':
				$context = $request->getContext();

				AppLocale::requireComponents(LOCALE_COMPONENT_APP_COMMON,  LOCALE_COMPONENT_PKP_MANAGER);
				$templateMgr = TemplateManager::getManager($request);
				$templateMgr->register_function('plugin_url', array($this, 'smartyPluginUrl'));

				$this->import('EmbedGalleySettingsForm');
				$form = new EmbedGalleySettingsForm($this, $context->getId());

				if ($request->getUserVar('save')) {
					$form->readInputData();
					if ($form->validate()) {
						$form->execute();
						return new JSONMessage(true);
					}
				} else {
					$form->initData();
				}
				return new JSONMessage(true, $form->fetch($request));
		}
		return parent::manage($args, $request);
	}

	/**
	 * Insert stylesheet and js
	 */
	function displayCallback($hookName, $params) {
		$template = $params[1];
		if ($template != 'frontend/pages/article.tpl') return false;
		$request = Application::get()->getRequest();
		$templateMgr = $params[0];
		$templateMgr->addStylesheet('embedGalley', $request->getBaseUrl() . DIRECTORY_SEPARATOR . $this->getPluginPath() . DIRECTORY_SEPARATOR . 'article.css');
		$templateMgr->addJavaScript('embedGalley', $request->getBaseUrl() . DIRECTORY_SEPARATOR . $this->getPluginPath() . DIRECTORY_SEPARATOR . 'embedGalley.js');
		$templateMgr->addJavaScript('mathJax', 'https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/latest.js?config=TeX-MML-AM_CHTML');
		return false;
	}

	/**
	 * Convert and embed html to abstract page footer
	 * @param $hookName string
	 * @param $params array
	 */
	function embedHtml($hookName, $params) {
		$smarty =& $params[1];
		$output =& $params[2];
		$publication = $smarty->getTemplateVars('publication');

		// TODO: handle language versions ie. multiple XML galleys. Check for current locale and use that. If not available fallback to primary locale and/or the XML version that is available
		$xmlGalley = null;
		foreach ($publication->getData('galleys') as $galley) {
			if ($galley && in_array($galley->getFileType(), array('application/xml', 'text/xml'))) {
				if ($publication->getId() === $galley->getData('publicationId')) {
		  			$xmlGalley = $galley;
		  			break;
				}
			}
		}

		// Return false if no XML galleys available
		// TODO: Check for article component -> Article text; check for multilingual
		if (!$xmlGalley) return false;
		
		$request = Application::getRequest();	

		// Parse XML to HTML		
		$html = $this->_parseXml($xmlGalley->getFile());

		// Parse HTML image url's etc.
		$html = $this->_parseHtmlContents($request, $html, $xmlGalley, $publication);

		// Assign HTML to article template
		$smarty->assign('html', $html);

		$output .= $smarty->fetch($this->getTemplateResource('articleFooter.tpl'));

		return false;
	}

	/**
	 * Return string containing the parsed HTML file.
	 * @param $xmlGalley JATS XML Galley file
	 * @return string
	 */
	function _parseXml($xmlGalley) {
		$contents = Services::get('file')->fs->read($xmlGalley->getData('path'));
		
		$document = new DOMDocument;
		$document->loadXML($contents, LIBXML_DTDLOAD | LIBXML_DTDVALID | LIBXML_NONET | LIBXML_NOENT);
	
		// TODO: use $citation_style to select the correct citation style from plugin settings, for now hardcoded here
		$citation_style = "APA"; 
		$document = $this->_generateHTML($document, $citation_style);

		$html = $document->saveHTML($document->documentElement);

		return $html;
	}

	/**
	 * Return string containing the parsed contents of the HTML file.
	 * This function performs any necessary filtering, like image URL replacement.
	 * @param $request PKPRequest
	 * @param $galley ArticleGalley
	 * @return string
	 */	
	function _parseHtmlContents($request, $contents, $galley, $publication) {
		$journal = $request->getJournal();
		$submissionFile = $galley->getFile();
		$submissionId = $submissionFile->getData('submissionId');

		// Replace media file references
		import('lib.pkp.classes.submission.SubmissionFile'); // Constants
		$embeddableFilesIterator = Services::get('submissionFile')->getMany([
			'assocTypes' => [ASSOC_TYPE_SUBMISSION_FILE],
			'assocIds' => [$submissionFile->getId()],
			'fileStages' => [SUBMISSION_FILE_DEPENDENT],
			'includeDependentFiles' => true,
		]);
		$embeddableFiles = iterator_to_array($embeddableFilesIterator);

		$referredArticle = null;
		$submissionDao = DAORegistry::getDAO('SubmissionDAO');

		foreach ($embeddableFiles as $embeddableFile) {
			$params = array();

			// Ensure that the $referredArticle object refers to the article we want
			if (!$referredArticle || $referredArticle->getId() != $submissionId) {
				$referredArticle = $submissionDao->getById($submissionId);
			}

			$fileUrl = $request->url(null, 'article', 'download', [$referredArticle->getBestId(), 'version', $galley->getData('publicationId'), $galley->getBestGalleyId(), $embeddableFile->getId(), $embeddableFile->getLocalizedData('name')], $params);
			$pattern = preg_quote(rawurlencode($embeddableFile->getLocalizedData('name')));

			$contents = preg_replace(
				'/([Ss][Rr][Cc]|[Hh][Rr][Ee][Ff]|[Dd][Aa][Tt][Aa])\s*=\s*"([^"]*' . $pattern . ')"/',
				'\1="' . $fileUrl . '"',
				$contents
			);
		}

		return $contents;
	}	

	/**
	 * Generate HTML from XML
	 * @param $input JATS XML DOMDocument
	 * @param $citation_style Style for references
	 * @return DOMdocument
	 */
    function _generateHTML(\DOMDocument $input, $citation_style){
		$path = Core::getBaseDir() . DIRECTORY_SEPARATOR . $this->getPluginPath() . DIRECTORY_SEPARATOR . 'xsl' . DIRECTORY_SEPARATOR . $citation_style . ".xsl";

        $stylesheet = new \DOMDocument();
        $stylesheet->load($path);

        $processor = new \XSLTProcessor();
        $processor->registerPHPFunctions([
            'rawurlencode',
            'EmbedGalleyPlugin::formatDate'
        ]);

        $processor->importStyleSheet($stylesheet);
        $doc = $processor->transformToDoc($input);
        $doc->formatOutput = true;
        return $doc;
    }

	/**
	 * Return string containing date
	 * @param $text String to be formatted
	 * @param $format Date format, default DATE_W3C
	 * @return string
	 */	
    public static function formatDate($text, $format = DATE_W3C){
        $date = new \DateTime($text);
        return $date->format($format);
    }
}
