<?xml version="1.0" encoding="UTF-8"?>

<!-- XSLT stylesheet converting City Archives Amsterdam examples -->
<!-- Endocoded Archival Description 2002 (EAD) into Records in Contexts Ontology (RiC-O) 0.1-->
<!-- Ivo Zandhuis (ivo@zandhuis.nl) 20200122 -->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:schema="http://schema.org/"
    xmlns:rico="https://www.ica.org/standards/RiC/ontology#">
<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
<xsl:strip-space elements="*"/>

<xsl:param name="baseUri">https://archief.amsterdam/archief/</xsl:param>

<!-- RDF wrap, looping hierarchy -->
<xsl:template match="ead">
    <rdf:RDF>
        <xsl:apply-templates select="archdesc"/>
    </rdf:RDF>
</xsl:template>

<!-- creating subjects -->
<xsl:template match="archdesc">
    <rico:RecordSet>
        <xsl:attribute name="rdf:about">
            <xsl:value-of select="$baseUri"/>
            <xsl:value-of select="did/unitid"/>
        </xsl:attribute>
        <xsl:apply-templates select="did"/>
        <xsl:call-template name="set-recordsettype">
            <xsl:with-param name="type" select="@level"/>
        </xsl:call-template>
    </rico:RecordSet>
    <xsl:apply-templates select="dsc">
        <xsl:with-param name="archnr" select="did/unitid"/>
    </xsl:apply-templates>
</xsl:template>

<xsl:template match="dsc">
    <xsl:param name="archnr"/>
    <xsl:apply-templates select="c">
        <xsl:with-param name="archnr" select="$archnr"/>
    </xsl:apply-templates>
</xsl:template>

<xsl:template match="c">
    <xsl:param name="archnr"/>
    <rico:RecordSet>
        <xsl:attribute name="rdf:about">
            <xsl:value-of select="$baseUri"/>
            <xsl:value-of select="$archnr"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="did/unitid/@identifier"/>
        </xsl:attribute>
        <xsl:if test="@level='file'">
            <schema:url>
                <xsl:value-of select="$baseUri"/>
                <xsl:value-of select="$archnr"/>
                <xsl:text>/</xsl:text>
                <xsl:value-of select="did/unitid"/>
            </schema:url>
        </xsl:if>
        <rico:includedIn>
            <xsl:choose>
                <xsl:when test="../../@level='fonds'">        
                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="$baseUri"/>
                        <xsl:value-of select="$archnr"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="$baseUri"/>
                        <xsl:value-of select="$archnr"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="../did/unitid/@identifier"/>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </rico:includedIn>  
        <xsl:call-template name="set-recordsettype">
            <xsl:with-param name="type" select="@level"/>
        </xsl:call-template>
        <xsl:apply-templates select="did"/>
    </rico:RecordSet>
    <xsl:apply-templates select="c">
        <xsl:with-param name="archnr" select="$archnr"/>
    </xsl:apply-templates>
</xsl:template>

<!-- creating predicates and objects -->
<!-- very preliminary mapping, created in my learning-by-doing way of working! -->
<!-- super minimal: only four basic fields, most important in Dutch Archival Culture -->
<xsl:template match="did">
    <xsl:apply-templates select="unitid"/>
    <xsl:apply-templates select="unittitle"/>
    <xsl:apply-templates select="unitdate"/>
    <xsl:apply-templates select="physdesc"/>
</xsl:template>

<xsl:template match="unitid">
    <rico:identifier>
        <xsl:value-of select="."/>
    </rico:identifier>
    <rico:identifier>
        <xsl:value-of select="@identifier"/>
    </rico:identifier>
</xsl:template>

<xsl:template match="unittitle">
    <rico:hasTitle>
        <xsl:value-of select="normalize-space(.)"/>
    </rico:hasTitle>
    <rdfs:label>
        <xsl:value-of select="normalize-space(.)"/>
    </rdfs:label>
</xsl:template>

<xsl:template match="unitdate">
    <rico:creationDate>
        <xsl:value-of select="."/>
    </rico:creationDate>
</xsl:template>

<xsl:template match="physdesc">
    <rico:recordResourceExtent>
        <xsl:value-of select="."/>
    </rico:recordResourceExtent>
</xsl:template>

<!-- named templates -->
<xsl:template name="set-recordsettype">
    <xsl:param name="type"/>
    <xsl:choose>
        <xsl:when test="$type = 'fonds'">
            <rico:hasRecordSetType>
                <xsl:attribute name="rdf:resource">
                    <xsl:text>https://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Fonds</xsl:text>
                </xsl:attribute>
            </rico:hasRecordSetType>
        </xsl:when>
        <xsl:when test="$type = 'collection'">
            <rico:hasRecordSetType>
                <xsl:attribute name="rdf:resource">
                    <xsl:text>https://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Collection</xsl:text>
                </xsl:attribute>
            </rico:hasRecordSetType>
        </xsl:when>
        <xsl:when test="$type = 'series'">
            <rico:hasRecordSetType>
                <xsl:attribute name="rdf:resource">
                    <xsl:text>https://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Series</xsl:text>
                </xsl:attribute>
            </rico:hasRecordSetType>
        </xsl:when>
        <xsl:when test="$type = 'subseries'">
            <rico:hasRecordSetType>
                <xsl:attribute name="rdf:resource">
                    <xsl:text>https://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Subseries</xsl:text>
                </xsl:attribute>
            </rico:hasRecordSetType>
        </xsl:when>
        <xsl:when test="$type = 'file'">
            <rico:hasRecordSetType>
                <xsl:attribute name="rdf:resource">
                    <xsl:text>https://www.ica.org/standards/RiC/vocabularies/recordSetTypes#File</xsl:text>
                </xsl:attribute>
            </rico:hasRecordSetType>
        </xsl:when>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
