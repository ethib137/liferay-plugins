<#assign sidebar_portlet = "">
<#assign sidebar_portlet_title = "">

<#if !layout.isPublicLayout()>
	<#assign sidebar_portlet = "5_WAR_soportlet">
	<#assign sidebar_portlet_title = languageUtil.get(locale, "javax.portlet.title.134")>
<#else>
	<#assign sidebar_portlet = "3_WAR_contactsportlet">
	<#assign sidebar_portlet_title = languageUtil.format(locale, "x's-contacts", current_user.getFirstName())>
</#if>

<hr />

<h3>${htmlUtil.escape(sidebar_portlet_title)}</h3>

${freeMarkerPortletPreferences.setValue("displayStyle", "0")}
${freeMarkerPortletPreferences.setValue("portletSetupShowBorders", "false")}

${theme.runtime(sidebar_portlet, "", freeMarkerPortletPreferences.toString())}

${freeMarkerPortletPreferences.reset()}