<#assign logo = "logo">
<#assign user_dashboard_portlet_url = site_default_url>
<#assign user_dashboard_url = site_default_url>
<#assign user_profile_url = community_default_public_url>

<#if company.getLogoId() == 0 && !layout.layoutSet.isLogo()>
	<#assign site_logo = images_folder + "/custom/so_logo.png">
	<#assign site_logo_height = "64px">
	<#assign site_logo_width = "186px">
</#if>

<#if is_signed_in>
	<#assign liferay_toggle_controls = sessionClicks.get(request, "liferay_toggle_controls", "")>

	<#if liferay_toggle_controls == "">
		${sessionClicks.put(request, "liferay_toggle_controls", "hidden")}
		<#assign liferay_toggle_controls = "hidden">
		<#assign css_class = css_class.replaceAll("controls-visible", "controls-hidden")>
	</#if>

	<#assign user_group = user.getGroup()>
	<#assign nav_css_class = nav_css_class + " sort-pages modify-pages">
	<#assign user_dashboard_portlet_url = portletURLFactory.create(request, "49", page.getPlid(), "ACTION_PHASE")>
	${user_dashboard_portlet_url.setParameter("struts_action", "/my_sites/view")}
	${user_dashboard_portlet_url.setParameter("groupId", "user_group.getGroupId()")}
	${user_dashboard_portlet_url.setParameter("privateLayout", "true")}
	${user_dashboard_portlet_url.setPortletMode("view")}
	${user_dashboard_portlet_url.setWindowState("normal")}
	<#assign user_dashboard_url = htmlUtil.escape(user_dashboard_portlet_url.toString())>
</#if>

<#if page_group.isUser()>
	<#assign user_local_service = serviceLocator.findService("com.liferay.portal.service.UserLocalService")>
	<#assign current_user = user_local_service.getUserById(page_group.getClassPK())>
	<#assign current_user_name = current_user.getFullName()>
	<#assign current_user_profile_url = theme_display.getURLPortal() + theme_display.getPathFriendlyURLPublic() + "/" + current_user.getScreenName()>
	<#assign current_user_profile_portrait_url = current_user.getPortraitURL(themeDisplay)>
	<#assign show_edit_profile_button = false>

	<#if current_user.getUserId() == user.getUserId() && layout.isPublicLayout()>
		<#assign group_local_service = serviceLocator.findService("com.liferay.portal.service.GroupLocalService")>
		<#assign control_panel_group = group_local_service.getGroup(company_id, "Control Panel")>
		<#assign layout_local_service = serviceLocator.findService("com.liferay.portal.service.LayoutLocalService")>
		<#assign control_panel_plid = layout_local_service.getDefaultPlid(control_panel_group.getGroupId(), true)>
		<#assign current_user_edit_profile_portrait_url = portletURLFactory.create(request, "2", control_panel_plid, "RENDER_PHASE")>
		${current_user_edit_profile_portrait_url.setParameter("struts_action", "/my_account/edit_user_portrait")}
		${current_user_edit_profile_portrait_url.setParameter("p_u_i_d", "user_id")}
		${current_user_edit_profile_portrait_url.setParameter("redirect", current_user_profile_url)}
		${current_user_edit_profile_portrait_url.setPortletMode("view")}
		${current_user_edit_profile_portrait_url.setWindowState("pop_up")}
		<#assign show_edit_profile_button = true>
	</#if>

	<#if current_user.getPortraitId() == 0>
		<#assign current_user_profile_portrait_url = images_folder + "/custom/so_user_profile_male_default.png">
	</#if>

	<#assign css_class = css_class + " user-group">
	<#assign user_detail_class = "so-user-detail">

	<#if page_group.getClassPK() == user_id>
		<#assign community_name = languageUtil.get(locale, "my-private-pages")>
	</#if>

	<#if layout.isPublicLayout()>
		<#assign the_title = current_user_name>
		<#assign css_class = css_class + " profile-page">
		<#assign user_detail_class = "user-profile-detail">
	</#if>
</#if>

<#assign layout_fluid = getterUtil.getBoolean(sessionClicks.get(request, "so-layout-fluid", "false"))>

<#if layout_fluid == true>
	<#assign css_class = css_class + " so-layout-fluid">
</#if>