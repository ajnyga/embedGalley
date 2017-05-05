<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="xlink"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink">

				
    <!-- page range(s) -->
    <xsl:template name="pagination">
        <xsl:choose>
            <xsl:when test="page-range">
                <xsl:apply-templates select="page-range" mode="citation"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="fpage" mode="citation"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="publication-type-label">
        <xsl:text>&#32;</xsl:text>
        <span class="{concat('label label-', @publication-type)}">
            <xsl:choose>
                <xsl:when test="@publication-type='working-paper'">
                    <xsl:text>preprint</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@publication-type"/>
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>

    <xsl:template match="issn" mode="citation">
        <span class="{local-name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- journal name -->
	<xsl:template match="source" mode="journal-citation">
		<span class="{local-name()}"
		      itemprop="isPartOf" itemscope="itemscope"
		      itemtype="http://schema.org/Periodical">
			<span itemprop="name">
				<xsl:apply-templates/>
			</span>
		</span>
	</xsl:template>

    <!-- report source -->
    <xsl:template match="source" mode="report-citation">
        <span class="{local-name()}">
            <xsl:apply-templates/>
        </span>
        <xsl:text>.</xsl:text>
        <xsl:text>&#32;</xsl:text>
    </xsl:template>

    <!-- other source -->
    <xsl:template match="source" mode="citation">
        <span class="{local-name()}">
            <xsl:apply-templates/>
        </span>
        <xsl:text>.</xsl:text>
        <xsl:text>&#32;</xsl:text>
    </xsl:template>

    <xsl:template match="institution" mode="report-citation">
        <span class="{local-name()}">
            <xsl:apply-templates/>
        </span>
        <xsl:text>&#32;</xsl:text>
    </xsl:template>

    <!-- thesis source -->
    <xsl:template match="source" mode="thesis-citation">
        <span class="{local-name()}">
            <xsl:apply-templates/>
        </span>
        <xsl:if test="following-sibling::institution">
            <xsl:text>,&#32;</xsl:text>
        </xsl:if>
        <xsl:text>&#32;</xsl:text>
    </xsl:template>

    <xsl:template match="institution" mode="thesis-citation">
        <span class="{local-name()}">
            <xsl:apply-templates/>
        </span>
        <xsl:if test="following-sibling::comment">
            <xsl:text>.</xsl:text>
        </xsl:if>
    </xsl:template>

    <!-- book source -->
    <xsl:template match="source | conf-name" mode="book-citation">
        <xsl:variable name="editors" select="../person-group[@person-group-type='editor']"/>

        <xsl:if test="../article-title">
            <xsl:text>In:&#32;</xsl:text>
        </xsl:if>

        <xsl:apply-templates select="$editors" mode="book-citation"/>

        <span itemprop="name">
            <xsl:apply-templates select="../series" mode="book-citation"/>
            <xsl:if test="not(../edition)">.</xsl:if>
        </span>
    </xsl:template>

    <!-- citation editor names -->
    <xsl:template match="person-group[@person-group-type='editor']" mode="book-citation">
        <xsl:variable name="editors" select="count(name)"/>
        <xsl:apply-templates select="name" mode="citation"/>
        <xsl:choose>
            <xsl:when test="$editors > 1">
                <xsl:text>, eds.&#32;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>, ed.&#32;</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="edition" mode="citation">
        <xsl:text>&#32;(</xsl:text>
        <span class="{local-name()}">
            <xsl:apply-templates/>
        </span>
        <xsl:apply-templates select="following-sibling::part-title" mode="book-citation-edition"/>
        <xsl:text>).</xsl:text>
    </xsl:template>

    <xsl:template match="edition" mode="software-citation">
        <xsl:text>&#32;(</xsl:text>
        <span class="{local-name()}">
            <xsl:apply-templates/>
        </span>
        <xsl:text>).</xsl:text>
    </xsl:template>

    <xsl:template match="version" mode="citation">
        <xsl:text>&#32;</xsl:text>
        <span class="version-container">
            <span class="{local-name()}">
                <xsl:apply-templates/>
            </span>
        </span>
        <xsl:text>&#32;</xsl:text>
    </xsl:template>

    <xsl:template match="part-title" mode="book-citation-edition">
        <xsl:text>,&#32;</xsl:text>
        <span class="{local-name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="series" mode="book-citation">
        <xsl:text>,&#32;</xsl:text>
        <span class="{local-name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="conf-sponsor" mode="citation">
        <xsl:text>&#32;</xsl:text>
        <span class="{local-name()}">
            <xsl:apply-templates/>
        </span>
        <xsl:text>.</xsl:text>
    </xsl:template>

    <xsl:template match="conf-loc" mode="citation">
        <xsl:text>&#32;</xsl:text>
        <span class="{local-name()}">
            <xsl:apply-templates/>
        </span>
        <xsl:choose>
            <xsl:when test="../conf-date">
                <xsl:text>,</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>.</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="conf-date" mode="citation">
        <xsl:text>&#32;</xsl:text>
        <span class="{local-name()}">
            <xsl:apply-templates/>
        </span>
        <xsl:text>.</xsl:text>
    </xsl:template>

    <xsl:template match="publisher-name | institution" mode="citation">
        <xsl:apply-templates select="../publisher-loc" mode="citation"/>
        <xsl:text>&#32;</xsl:text>
        <span class="publisher">
            <xsl:apply-templates/>
        </span>
        <xsl:text>.</xsl:text>
    </xsl:template>

    <xsl:template match="publisher-loc" mode="citation">
        <xsl:text>&#32;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>:</xsl:text>
    </xsl:template>

    <!-- link out from a citation title -->
    <xsl:template name="citation-url">
        <xsl:param name="citation"/>

        <xsl:variable name="doi" select="$citation/pub-id[@pub-id-type='doi']"/>
        <xsl:variable name="uri" select="$citation/uri"/>
		
        <xsl:choose>
            <xsl:when test="$doi">
                <a href="{concat('https://doi.org/', $doi)}">
					<xsl:value-of select="concat('https://doi.org/', $doi)"/>
				</a>
            </xsl:when>
            <xsl:when test="$uri/@xlink:href">
				<a href="{$uri/@xlink:href}">
				<xsl:value-of select="$uri/@xlink:href"/>
				</a>
			</xsl:when>
            <xsl:when test="$uri">
                <a href="{$uri}">
				<xsl:value-of select="$uri"/>
				</a>
			</xsl:when>

        </xsl:choose>
    </xsl:template>

    <xsl:template match="article-title | data-title" mode="citation">
        <xsl:apply-templates select="node()|@*"/>
        <xsl:apply-templates select="../named-content[@content-type='abstract-details']" mode="citation"/>
    </xsl:template>

    <!-- eg " abstract no. 35" -->
    <xsl:template match="named-content[@content-type='abstract-details']" mode="citation">
        <xsl:value-of select="concat(' [', ., ']')"/>
    </xsl:template>

	<xsl:template match="volume" mode="journal-citation">
		<span class="{local-name()}"
		      itemprop="isPartOf" itemscope="itemscope"
		      itemtype="http://schema.org/PublicationVolume">
			<xsl:apply-templates select="../source" mode="journal-citation"/>
			<xsl:text>&#32;</xsl:text>
			<span itemprop="volumeNumber">
				<xsl:apply-templates/>
			</span>
		</span>
	</xsl:template>

    <xsl:template match="volume" mode="citation">
        <span class="{local-name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

	<xsl:template match="issue" mode="journal-citation">
		<span class="{local-name()}"
		      itemprop="isPartOf" itemscope="itemscope"
		      itemtype="http://schema.org/PublicationIssue">
			<!-- if a volume exists, the source is part of it -->
			<xsl:choose>
				<xsl:when test="../volume">
					<xsl:apply-templates select="../volume" mode="journal-citation"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="../source" mode="journal-citation"/>
					<xsl:text>&#32;</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>(</xsl:text>
			<span itemprop="issueNumber">
				<xsl:apply-templates/>
			</span>
			<xsl:text>)</xsl:text>
		</span>
	</xsl:template>

    <xsl:template match="elocation-id" mode="citation">
        <xsl:if test="../volume">
            <xsl:text>, &#32;</xsl:text>
        </xsl:if>
        <span class="{local-name()}" itemprop="pageStart">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="page-range" mode="citation">
        <xsl:if test="../volume">
            <xsl:text>,&#32;</xsl:text>
        </xsl:if>
        <span class="{local-name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="fpage" mode="citation">
        <xsl:if test="../volume">
            <xsl:text>,&#32;</xsl:text>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="../lpage and . != ../lpage">
                <span class="{local-name()}" itemprop="pageStart">
                    <xsl:apply-templates/>
                </span>
                <xsl:text>-</xsl:text>
                <span class="lpage" itemprop="pageEnd">
                    <xsl:value-of select="../lpage"/>
                </span>
				<xsl:text>.</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <span class="{local-name()}" itemprop="pageStart">
                    <xsl:apply-templates/>
                </span>
				<xsl:text>.</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="year" mode="citation">
        <span class="{local-name()}" itemprop="datePublished">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="comment" mode="citation">
        <span class="{local-name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
	
    <!-- comments, access date -->
    <xsl:template name="comment">
        <xsl:apply-templates select="comment" mode="citation"/>
        <xsl:apply-templates select="date-in-citation[@content-type='access-date']" mode="citation"/>
    </xsl:template>

    <!-- citation author names -->
    <xsl:template name="authors">
        <xsl:variable name="authors" select="person-group[not(@person-group-type='editor')]"/>
        <xsl:variable name="author-names" select="$authors/name | $authors/collab"/>
		

        <xsl:if test="$author-names">
            <span class="citation-authors">
				<xsl:apply-templates select="$author-names" mode="citation"/>
            </span>
        </xsl:if>
    </xsl:template>	
	

    <!-- name -->
    <xsl:template match="name" mode="citation">
        <xsl:variable name="person-type" select="parent::person-group/@person-group-type"/>

        <span class="{local-name()}" itemprop="author" itemscope="itemscope" itemtype="http://schema.org/Person">
            <xsl:apply-templates select="surname"/>
            <xsl:if test="given-names">
                <xsl:text>,&#32;</xsl:text>
                
				<xsl:apply-templates select="given-names"/>
				
            </xsl:if>
        </span>

        <xsl:if test="$person-type != '' and $person-type != 'author' and $person-type != 'editor'">
            <xsl:text>&#32;(</xsl:text>
            <span class="person-type">
                <xsl:call-template name="ucfirst">
                    <xsl:with-param name="text" select="$person-type"/>
                </xsl:call-template>
            </span>
            <xsl:text>)</xsl:text>
        </xsl:if>

        <xsl:call-template name="comma-separator"/>
    </xsl:template>

    <!-- collaboration name -->
    <xsl:template match="collab" mode="citation">
        <span class="{local-name()}" itemprop="author" itemscope="itemscope">
            <xsl:apply-templates/>
        </span>
        <xsl:call-template name="comma-separator"/>
    </xsl:template>				
    <!-- access date -->
    <xsl:template match="date-in-citation[@content-type='access-date']" mode="citation">
        <xsl:text>&#32;</xsl:text>
        <span class="access-date">
            <xsl:text>(accessed&#32;</xsl:text>
            <time class="{local-name()}" datetime="{@iso-8601-date}">
                <xsl:apply-templates/>
            </time>
            <xsl:text>)</xsl:text>
        </span>
    </xsl:template>

    <!-- link out from a citation title -->
    <xsl:template name="citation-backlink">
		<a class="ref-back-button">
			<i class="fa fa-arrow-left" aria-hidden="true"></i>
		</a>
    </xsl:template>
	


</xsl:stylesheet>
