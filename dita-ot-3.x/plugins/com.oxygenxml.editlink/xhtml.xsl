<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:editlink="http://oxygenxml.com/xslt/editlink/"
    exclude-result-prefixes="xs editlink"
    version="2.0">
  
  <xsl:import href="link.xsl"/>
  
  <xsl:param name="editlink.remote.ditamap.url"/>
  <xsl:param name="editlink.web.author.url"/>
  <xsl:param name="editlink.present.only.path.to.topic"/>
  <xsl:param name="editlink.local.ditamap.path"/>
  
  
  <!-- Override the topic/title processing to add 'Edit Link' action. -->  
  <xsl:template match="*[contains(@class, ' topic/topic ')]/*[contains(@class, ' topic/title ')]">
    <xsl:choose>
      <xsl:when test="string-length($editlink.remote.ditamap.url) > 0 
        or $editlink.present.only.path.to.topic = 'true'">
        <!-- Get the default output in a temporary variable -->
        <xsl:variable name="topicTitleFragment">
          <xsl:next-match/>
        </xsl:variable>
        
        <!-- Process the generated HTML to add the 'Edit Link' action -->
        <xsl:apply-templates select="$topicTitleFragment" mode="add-edit-link">
          <xsl:with-param name="xtrf" select="@xtrf" tunnel="yes"/>
        </xsl:apply-templates>  
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
         
  </xsl:template>
  
  <!-- Add a span element associated with the 'Edit Link' action -->
  <xsl:template match="*[starts-with(local-name(), 'h')]" mode="add-edit-link" priority="5">
    <xsl:param name="xtrf" tunnel="yes"/>
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="style">display:table; width:100%;</xsl:attribute>
      <div class="edit-link-container">
        <xsl:apply-templates select="node()" mode="#current"/>  
      </div>
      
      <!-- The edit link -->
      <span class="edit-link">
        <xsl:choose>
          <xsl:when test="$editlink.present.only.path.to.topic = 'true'">
            <xsl:value-of select="editlink:makeRelative(editlink:toUrl($editlink.local.ditamap.path), $xtrf)"/>
          </xsl:when>
          <xsl:otherwise>
            <a target="_blank">
              <xsl:attribute name="href">
                <xsl:value-of select="editlink:compute($editlink.remote.ditamap.url, $editlink.local.ditamap.path, $xtrf, $editlink.web.author.url)"/>
              </xsl:attribute>Edit online</a>
          </xsl:otherwise>
        </xsl:choose>
      </span>
      <style type="text/css">
        .edit-link {
          display: table-cell;
          font-size: 12px;
          opacity: 0.6;
          text-align: right;
          vertical-align: "middle"
        }
        .edit-link-container {
          display: table-cell;
          margin-top: 0
        }
      </style>
      <!-- Done with the edit link -->
    </xsl:copy>
  </xsl:template>

  <!-- Copy template for the add-edit-link mode -->
  <xsl:template match="node() | @*" mode="add-edit-link">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>