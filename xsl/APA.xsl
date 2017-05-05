<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="xlink"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink">

	<xsl:include href="jats-to-html.xsl"/>
	<xsl:include href="citations.xsl"/>
				
    <!-- journal citation -->
    <xsl:template match="element-citation[@publication-type='journal']">
        
		<xsl:call-template name="authors" />
		<xsl:text>&#32;</xsl:text>
		
		<xsl:text>(</xsl:text>
		<xsl:apply-templates select="date/year | year" mode="citation"/>
		<xsl:text>)</xsl:text>
		<xsl:text>.&#32;</xsl:text>
		
        <cite itemprop="name">
            <xsl:apply-templates select="article-title" mode="citation"/>
			<xsl:call-template name="title-punctuation"/>
        </cite>
		<xsl:text>&#32;</xsl:text>
        
        <span>
	        <xsl:choose>
		        <xsl:when test="issue">
			        <!-- if an issue exists, the source and volume are part of it -->
			        <xsl:apply-templates select="issue" mode="journal-citation"/>
		        </xsl:when>
		        <xsl:when test="volume">
			        <!-- if a volume exists, the source is part of it -->
			        <xsl:apply-templates select="volume" mode="journal-citation"/>
		        </xsl:when>
		        <xsl:otherwise>
			        <xsl:apply-templates select="source" mode="journal-citation"/>
			        <xsl:text>&#32;</xsl:text>
		        </xsl:otherwise>
	        </xsl:choose>
			
			
			<xsl:call-template name="pagination"/>
			
            <xsl:call-template name="comment"/>
			<xsl:text>&#32;</xsl:text>
            <xsl:call-template name="citation-url">
                <xsl:with-param name="citation" select="."/>
            </xsl:call-template>
			
        </span>
		<xsl:text>&#32;</xsl:text>
		<xsl:call-template name="citation-backlink">
			<xsl:with-param name="citation" select="."/>
		</xsl:call-template>
		
    </xsl:template>

	
	
	
    <!-- book citations -->
    <xsl:template match="element-citation[@publication-type='book']">
        
		
		<xsl:call-template name="authors" />
		<xsl:text>&#32;</xsl:text>
		
		<xsl:text>(</xsl:text>
		<xsl:apply-templates select="date/year | year" mode="citation"/>
		<xsl:text>)</xsl:text>
		<xsl:text>.&#32;</xsl:text>		
		
        <cite class="article-title">
            <xsl:apply-templates select="article-title" mode="citation"/>
			<xsl:call-template name="title-punctuation"/>
        </cite>
		<xsl:text>&#32;</xsl:text>
		
        <xsl:text>&#32;</xsl:text>
        <xsl:apply-templates select="source" mode="book-citation"/>
        <span>
            <xsl:apply-templates select="edition" mode="citation"/>
            <xsl:text>&#32;</xsl:text>
            <xsl:apply-templates select="publisher-name | institution" mode="citation"/>
            <xsl:text>&#32;</xsl:text>
            <xsl:apply-templates select="volume" mode="citation"/>
			<xsl:text>.</xsl:text>
            <xsl:call-template name="pagination"/>
            <xsl:text>&#32;</xsl:text>
            <xsl:apply-templates select="pub-id[@pub-id-type='isbn']" mode="citation"/>
            <xsl:call-template name="comment"/>
            <xsl:call-template name="citation-url">
                <xsl:with-param name="citation" select="."/>
            </xsl:call-template>			
        </span>
		<xsl:text>&#32;</xsl:text>
		<xsl:call-template name="citation-backlink">
			<xsl:with-param name="citation" select="."/>
		</xsl:call-template>		
    </xsl:template>

    <!-- conference proceedings -->
    <xsl:template match="element-citation[@publication-type='conf-proceedings']
					   | element-citation[@publication-type='confproc']">
        <xsl:call-template name="authors"/>
        <cite class="article-title">
            <xsl:apply-templates select="article-title" mode="citation"/>
        </cite>
        <xsl:text>&#32;</xsl:text>
        <xsl:apply-templates select="conf-name | source" mode="book-citation"/>
        <span>
            <xsl:apply-templates select="conf-loc" mode="citation"/>
            <xsl:apply-templates select="conf-date" mode="citation"/>
            <xsl:apply-templates select="conf-sponsor" mode="citation"/>
            <xsl:text>&#32;</xsl:text>
            <xsl:apply-templates select="edition" mode="citation"/>
            <xsl:text>&#32;</xsl:text>
            <xsl:apply-templates select="publisher-name | institution" mode="citation"/>
            <xsl:text>&#32;</xsl:text>
            <xsl:apply-templates select="volume" mode="citation"/>
            <xsl:call-template name="pagination"/>
            <xsl:text>&#32;</xsl:text>
            <xsl:apply-templates select="pub-id[@pub-id-type='isbn']" mode="citation"/>
            <xsl:call-template name="comment"/>
			<xsl:call-template name="citation-url">
                <xsl:with-param name="citation" select="."/>
            </xsl:call-template>
        </span>
		<xsl:text>&#32;</xsl:text>
		<xsl:call-template name="citation-backlink">
			<xsl:with-param name="citation" select="."/>
		</xsl:call-template>		
    </xsl:template>

    <!-- report citations -->
    <xsl:template match="element-citation[@publication-type='report']">
        <xsl:call-template name="authors"/>
		<xsl:text>&#32;</xsl:text>
		<xsl:text>(</xsl:text>
		<xsl:apply-templates select="date/year | year" mode="citation"/>
		<xsl:text>)</xsl:text>
		<xsl:text>.&#32;</xsl:text>	
		
        <cite class="article-title">
            <xsl:apply-templates select="article-title" mode="citation"/>
            <xsl:call-template name="title-punctuation"/>
			<xsl:text>&#32;</xsl:text>
            <xsl:apply-templates select="source" mode="report-citation"/>
        </cite>
		<xsl:text>&#32;</xsl:text>
		
        <xsl:apply-templates select="institution" mode="report-citation"/>
        <xsl:apply-templates select="volume" mode="citation"/>
        <xsl:call-template name="pagination"/>
        <xsl:call-template name="comment"/>
		<xsl:call-template name="citation-url">
			<xsl:with-param name="citation" select="."/>
        </xsl:call-template>
		<xsl:text>&#32;</xsl:text>
		<xsl:call-template name="citation-backlink">
			<xsl:with-param name="citation" select="."/>
		</xsl:call-template>		
    </xsl:template>

    <!-- thesis citations -->
    <xsl:template match="element-citation[@publication-type='thesis']">
        <xsl:call-template name="authors"/>
        <cite class="article-title">
            <xsl:apply-templates select="article-title" mode="citation"/>
        </cite>
        <xsl:text>&#32;</xsl:text>
        <xsl:apply-templates select="source" mode="thesis-citation"/>
        <xsl:apply-templates select="institution" mode="thesis-citation"/>
        <xsl:call-template name="comment"/>
        <xsl:call-template name="publication-type-label"/>
		<xsl:text>&#32;</xsl:text>
		<xsl:call-template name="citation-backlink">
			<xsl:with-param name="citation" select="."/>
		</xsl:call-template>		
    </xsl:template>

    <!-- working paper (preprint) citations -->
    <xsl:template match="element-citation[@publication-type='working-paper']">
        <xsl:call-template name="authors"/>
        <cite class="article-title">
            <xsl:apply-templates select="article-title" mode="citation"/>
        </cite>
        <xsl:apply-templates select="version" mode="citation"/>
        <xsl:call-template name="comment"/>
        <xsl:call-template name="publication-type-label"/>
		<xsl:text>&#32;</xsl:text>
		<xsl:call-template name="citation-backlink">
			<xsl:with-param name="citation" select="."/>
		</xsl:call-template>		
    </xsl:template>

    <!-- software citations -->
    <xsl:template match="element-citation[@publication-type='software']">
        <xsl:call-template name="authors"/>
        <cite class="article-title">
            <!-- the title may be in "data-title" (since JATS 1.1) or "source" -->
            <xsl:choose>
                <xsl:when test="data-title">
                    <xsl:apply-templates select="data-title" mode="citation"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="source" mode="citation"/>
                </xsl:otherwise>
            </xsl:choose>
        </cite>
        <!-- if the title is in "data-title", "source" is used for the host -->
        <xsl:if test="data-title">
            <xsl:apply-templates select="source" mode="citation"/>
        </xsl:if>
        <span>
            <xsl:choose>
                <xsl:when test="version">
                    <xsl:apply-templates select="version" mode="citation"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="edition" mode="software-citation"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="publisher-name | institution" mode="citation"/>
        </span>
        <xsl:call-template name="comment"/>
        <xsl:call-template name="publication-type-label"/>
		<xsl:text>&#32;</xsl:text>
		<xsl:call-template name="citation-backlink">
			<xsl:with-param name="citation" select="."/>
		</xsl:call-template>		
    </xsl:template>

    <!-- data citations -->
    <xsl:template match="element-citation[@publication-type='data']">
        <xsl:call-template name="authors"/>
        <cite class="article-title">
            <xsl:apply-templates select="data-title" mode="citation"/>
        </cite>
        <xsl:text>&#32;</xsl:text>
        <xsl:apply-templates select="source" mode="citation"/>
        <xsl:apply-templates select="version" mode="citation"/>
        <xsl:call-template name="comment"/>
        <xsl:call-template name="publication-type-label"/>
		<xsl:text>&#32;</xsl:text>
		<xsl:call-template name="citation-backlink">
			<xsl:with-param name="citation" select="."/>
		</xsl:call-template>		
    </xsl:template>

    <!-- tweet citations -->
    <xsl:template match="element-citation[@publication-type='tweet']">
        <!-- assuming only one author -->
        <xsl:variable name="name-alternatives" select="person-group[@person-group-type='author']/name-alternatives"/>

        <span class="citation-authors-year">
            <b>
                <xsl:apply-templates select="$name-alternatives/name" mode="citation"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="concat('(@', $name-alternatives/string-name[@content-type='twitter-username'], ')')"/>
                <xsl:text>.</xsl:text>
            </b>
            <xsl:apply-templates select="year" mode="citation"/>
        </span>
        <xsl:text>&#32;</xsl:text>
        <cite class="article-title">
            <xsl:apply-templates select="article-title" mode="citation"/>
        </cite>
        <xsl:text>&#32;</xsl:text>
        <!-- TODO: hyperlink the date instead? -->
        <time datetime="{date[@date-type='pub']/@iso-8601-date}">
            <xsl:call-template name="format-date">
                <xsl:with-param name="value" select="date[@date-type='pub']/@iso-8601-date"/>
                <xsl:with-param name="format" select="'g:i A - j M Y'"/>
            </xsl:call-template>
        </time>
        <xsl:text>&#32;</xsl:text>
        <xsl:call-template name="publication-type-label"/>
		<xsl:text>&#32;</xsl:text>
		<xsl:call-template name="citation-backlink">
			<xsl:with-param name="citation" select="."/>
		</xsl:call-template>		
    </xsl:template>

    <!-- "other" citations -->
    <xsl:template match="element-citation[@publication-type='other']">
        <xsl:call-template name="authors"/>
        <cite class="article-title">
            <xsl:apply-templates select="article-title" mode="citation"/>
        </cite>
        <xsl:text>&#32;</xsl:text>
        <xsl:apply-templates select="source" mode="citation"/>
        <span>
            <xsl:apply-templates select="edition" mode="citation"/>
            <xsl:text>&#32;</xsl:text>
            <xsl:apply-templates select="publisher-name | institution" mode="citation"/>
            <xsl:text>&#32;</xsl:text>
            <xsl:apply-templates select="volume" mode="citation"/>
            <xsl:call-template name="pagination"/>
            <xsl:text>&#32;</xsl:text>
            <xsl:apply-templates select="pub-id[@pub-id-type='isbn']" mode="citation"/>
            <xsl:call-template name="comment"/>
			<xsl:call-template name="citation-url">
                <xsl:with-param name="citation" select="."/>
            </xsl:call-template>
        </span>
		<xsl:text>&#32;</xsl:text>
		<xsl:call-template name="citation-backlink">
			<xsl:with-param name="citation" select="."/>
		</xsl:call-template>		
    </xsl:template>

    <!-- other citations (?) -->
    <xsl:template match="element-citation">
        
		<xsl:call-template name="authors" />
		<xsl:text>&#32;</xsl:text>
		
		<xsl:text>(</xsl:text>
		<xsl:apply-templates select="date/year | year" mode="citation"/>
		<xsl:text>)</xsl:text>
		<xsl:text>.&#32;</xsl:text>		
		
        <cite class="article-title">
            <xsl:apply-templates select="article-title" mode="citation"/>
			<xsl:call-template name="title-punctuation"/>
        </cite>
		<xsl:text>&#32;</xsl:text>		
		
        <xsl:apply-templates select="source" mode="citation"/>
		<xsl:call-template name="comment"/>
		<xsl:call-template name="citation-url">
			<xsl:with-param name="citation" select="."/>
        </xsl:call-template>
		<xsl:text>&#32;</xsl:text>
		<xsl:call-template name="citation-backlink">
			<xsl:with-param name="citation" select="."/>
		</xsl:call-template>		
    </xsl:template>
	

	<!-- Other APA style specific templates -->
	
    <xsl:template match="given-names">
        <span class="{local-name()}" itemprop="givenName">
			<xsl:value-of select="substring(node()|@*,1,1)"/>
			<xsl:text>.</xsl:text>
        </span>
    </xsl:template>
	


</xsl:stylesheet>
