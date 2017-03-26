<?php

/**
 * @defgroup plugins_generic_embedGalley embedGalley Plugin
 */
 
/**
 * @file plugins/generic/embedGalley/index.php
 *
 * Copyright (c) 2014-2017 Simon Fraser University
 * Copyright (c) 2003-2017 John Willinsky
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @ingroup plugins_generic_embedGalley
 * @brief Wrapper for embedGalley plugin.
 *
 */

require_once('EmbedGalleyPlugin.inc.php');

return new EmbedGalleyPlugin();

?>
