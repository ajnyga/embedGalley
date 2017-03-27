<?php

/**
 * @file plugins/generic/embedGalley/EmbedGalleyPlugin.inc.php
 *
 * Copyright (c) 2014-2017 Simon Fraser University
 * Copyright (c) 2003-2017 John Willinsky
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
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
			
			// Convert JATS XML to HTML and embed to abstact page
			// TODO: how do you define a sequence for all plugins using this hook?
			HookRegistry::register('Templates::Article::Footer::PageFooter', array($this, 'embedHtml'));
		
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
	 * Convert and embed html to abstract page footer
	 * @param $hookName string
	 * @param $params array
	 */
	function embedHtml($hookName, $params) {
		$smarty =& $params[1];
		$output =& $params[2];
		
		// Search for XML galleys
		// TODO: handle language versions ie. multiple XML galleys. Check for current locale and use that. If not available fallback to primary locale and/or the XML version that is available
		$xmlGalley = null;
		$article = $smarty->get_template_vars('article');
		$galleys = $article->getGalleys();
		
		foreach ($article->getGalleys() as $galley) {
			if ($galley && in_array($galley->getFileType(), array('application/xml', 'text/xml'))) {
				$xmlGalley = $galley->getFile();
			}
		}
		
		// Return false if no XML galleys available
		if (!$xmlGalley) return false;
				
		// Parse XML to HTML
		$html = $this->_parseXml($xmlGalley->getFilePath());

		// Assign HTML to article template
		$smarty->assign('html', $html);
		$output .= $smarty->fetch($this->getTemplatePath() . 'articleFooter.tpl');

		return false;
		
	}

	/**
	 * Return string containing the parsed HTML file.
	 * @param $xml JATS XML Article
	 * @return HTML article
	 */
	function _parseXml($xmlGalleyPath) {
		
		# Use PeerJ jats-conversion
		# https://github.com/PeerJ/jats-conversion | MIT License (MIT)
		require $this->getPluginPath() . '/lib/jats-conversion/src/PeerJ/Conversion/JATS.php';
		$jats = new \PeerJ\Conversion\JATS;
		
		$document = new DOMDocument;
		$document->load($xmlGalleyPath, LIBXML_DTDLOAD | LIBXML_DTDVALID | LIBXML_NONET | LIBXML_NOENT);
		
		$document = $jats->generateHTML($document);		
		$html = $document->saveHTML($document->documentElement);
		
		return $html;
		
	}


	
}



?>
