<?php

/**
 * @file plugins/generic/embedGalley/EmbedGalleySettingsForm.inc.php
 *
 * Copyright (c) 2014-2017 Simon Fraser University
 * Copyright (c) 2003-2017 John Willinsky
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @class embedGalleySettingsForm
 * @ingroup plugins_generic_embedGalley
 *
 * @brief Form for journal managers to modify embedGalley plugin settings
 */

import('lib.pkp.classes.form.Form');

class EmbedGalleySettingsForm extends Form {

	/** @var int */
	var $_journalId;

	/** @var object */
	var $_plugin;

	/**
	 * Constructor
	 * @param $plugin EmbedGalleyPlugin
	 * @param $journalId int
	 */
	function __construct($plugin, $journalId) {
		$this->_journalId = $journalId;
		$this->_plugin = $plugin;

		parent::__construct($plugin->getTemplatePath() . 'settingsForm.tpl');


		$this->addCheck(new FormValidatorPost($this));
		$this->addCheck(new FormValidatorCSRF($this));
		
	}

	/**
	 * Initialize form data.
	 */
	function initData() {
		
		
	}

	/**
	 * Assign form data to user-submitted data.
	 */
	function readInputData() {
	
	
	}

	/**
	 * Fetch the form.
	 * @copydoc Form::fetch()
	 */
	function fetch($request) {
		$templateMgr = TemplateManager::getManager($request);
		$templateMgr->assign('pluginName', $this->_plugin->getName());
		return parent::fetch($request);
	}

	/**
	 * Save settings.
	 */
	function execute() {
		
	
	}
}

?>
