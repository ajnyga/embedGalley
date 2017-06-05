<?php

/**
 * @file plugins/generic/embedGalley/EmbedGalleyPlugin.inc.php
 *
 * Copyright (c) 2014-2017 Simon Fraser University
 * Copyright (c) 2003-2017 John Willinsky
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * The Federation of Finnish Learned Societies
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
	function register($category, $path) {
		$success = parent::register($category, $path);
		if (!Config::getVar('general', 'installed') || defined('RUNNING_UPGRADE')) return true;
		if ($success && $this->getEnabled()) {
			
			HookRegistry::register('Templates::Article::Footer::PageFooter', array($this, 'embedHtml'));
			
			#HookRegistry::register('Templates::Article::Footer::PageFooter', array($this, 'embedHtml'), HOOK_SEQUENCE_NORMAL);
			
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
	 * @copydoc Plugin::getActions()
	 */
	function getActions($request, $verb) {
		$router = $request->getRouter();
		import('lib.pkp.classes.linkAction.request.AjaxModal');
		return array_merge(
			$this->getEnabled()?array(
				new LinkAction(
					'settings',
					new AjaxModal(
						$router->url($request, null, null, 'manage', null, array('verb' => 'settings', 'plugin' => $this->getName(), 'category' => 'generic')),
						$this->getDisplayName()
					),
					__('manager.plugins.settings'),
					null
				),
			):array(),
			parent::getActions($request, $verb)
		);
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
	 * @copydoc PKPPlugin::getTemplatePath
	 */
	function getTemplatePath($inCore = false) {
		return parent::getTemplatePath($inCore) . 'templates/';
	}

	
	
	/**
	 * Insert stylesheet and js
	 */
	function displayCallback($hookName, $params) {

		$template = $params[1];
			
		if ($template != 'frontend/pages/article.tpl') return false;
		
		$templateMgr = $params[0];
		$templateMgr->addStylesheet('embedGalley', Request::getBaseUrl() . DIRECTORY_SEPARATOR . $this->getPluginPath() . DIRECTORY_SEPARATOR . 'article.css');
		$templateMgr->addJavaScript('embedGalley', Request::getBaseUrl() . DIRECTORY_SEPARATOR . $this->getPluginPath() . DIRECTORY_SEPARATOR . 'embedGalley.js');
		$templateMgr->addJavaScript('mathJax', '//cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=MML_HTMLorMML-full');
		
		return false;
	}
	
	
	/**
	 * Convert and embed html to abstract page footer
	 * @param $hookName string
	 * @param $params array
	 */
	function embedHtml($hookName, $params) {
		$smarty =& $params[1];
		
		$article = $smarty->get_template_vars('article');
		assert(is_a($article, 'PublishedArticle'));
		
		$genreDao = DAORegistry::getDAO('GenreDAO');
		
		foreach ($article->getLocalizedGalleys() as $galley) {
			if ($galley && !$galley->getRemoteURL() && in_array($galley->getFileType(), array('application/xml', 'text/xml')))
			{			
				$galleyFile = $galley->getFile();
				$genre = $genreDao->getById($galleyFile->getGenreId());
				if (!$genre->getSupplementary()) {
					$xmlGalley = $galley;
				}	
			}
		}
		
		// Return false if no XML galleys available
		if (!$xmlGalley) return false;

		$output =& $params[2];
		$request = Application::getRequest();	
		
		// Parse XML to HTML		
		$html = $this->_parseXml($xmlGalley->getFile());
		
		// Parse HTML image url's etc.
		$html = $this->_parseHtmlContents($request, $html, $xmlGalley);
		
		// Assign HTML to article template
		$smarty->assign('html', $html);
		
		$output .= $smarty->fetch($this->getTemplatePath() . 'articleFooter.tpl');
		
		return false;
		
	}

	/**
	 * Return string containing the parsed HTML file.
	 * @param $xmlGalley JATS XML Galley file
	 * @return string
	 */
	function _parseXml($xmlGalley) {
		
		$document = new DOMDocument;
		$document->load($xmlGalley->getFilePath());
		
		// TODO: use $citation_style to select the correct citation style from plugin settings, for now APA is hardcoded here
		$citation_style = "APA"; 
				
		$xslpath = Core::getBaseDir() . DIRECTORY_SEPARATOR . $this->getPluginPath() . DIRECTORY_SEPARATOR . 'xsl' . DIRECTORY_SEPARATOR . $citation_style . ".xsl";
		
        $stylesheet = new DOMDocument;
        $stylesheet->load($xslpath);

        $processor = new XSLTProcessor;
        $processor->registerPHPFunctions([
            'rawurlencode',
            'EmbedGalleyPlugin::formatDate'
        ]);
        $processor->importStyleSheet($stylesheet);
		
        $document = $processor->transformToDoc($document);
        $document->formatOutput = true;		
		
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
	function _parseHtmlContents($request, $contents, $galley) {
		$journal = $request->getJournal();
		$submissionFile = $galley->getFile();

		// Replace media file references
		$submissionFileDao = DAORegistry::getDAO('SubmissionFileDAO');
		import('lib.pkp.classes.submission.SubmissionFile'); // Constants
		$embeddableFiles = array_merge(
			$submissionFileDao->getLatestRevisions($submissionFile->getSubmissionId(), SUBMISSION_FILE_PROOF),
			$submissionFileDao->getLatestRevisionsByAssocId(ASSOC_TYPE_SUBMISSION_FILE, $submissionFile->getFileId(), $submissionFile->getSubmissionId(), SUBMISSION_FILE_DEPENDENT)
		);
		$referredArticle = null;
		$articleDao = DAORegistry::getDAO('ArticleDAO');

		foreach ($embeddableFiles as $embeddableFile) {
			$params = array();

			// Ensure that the $referredArticle object refers to the article we want
			if (!$referredArticle || $referredArticle->getId() != $galley->getSubmissionId()) {
				$referredArticle = $articleDao->getById($galley->getSubmissionId());
			}
			$fileUrl = $request->url(null, 'article', 'download', array($referredArticle->getBestArticleId(), $galley->getBestGalleyId(), $embeddableFile->getFileId()), $params);
			$pattern = preg_quote($embeddableFile->getOriginalFileName());

			$contents = preg_replace(
				'/([Ss][Rr][Cc]|[Hh][Rr][Ee][Ff]|[Dd][Aa][Tt][Aa])\s*=\s*"([^"]*' . $pattern . ')"/',
				'\1="' . $fileUrl . '"',
				$contents
			);


		}

		return $contents;
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



?>
