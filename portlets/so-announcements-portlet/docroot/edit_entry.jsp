<%--
/**
 * Copyright (c) 2000-2013 Liferay, Inc. All rights reserved.
 *
 * This file is part of Liferay Social Office. Liferay Social Office is free
 * software: you can redistribute it and/or modify it under the terms of the GNU
 * Affero General Public License as published by the Free Software Foundation,
 * either version 3 of the License, or (at your option) any later version.
 *
 * Liferay Social Office is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License
 * for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * Liferay Social Office. If not, see http://www.gnu.org/licenses/agpl-3.0.html.
 */
--%>

<%@ include file="/init.jsp" %>

<%
String redirect = ParamUtil.getString(request, "redirect");

long entryId = ParamUtil.getLong(request, "entryId");
AnnouncementsEntry entry = AnnouncementsEntryLocalServiceUtil.fetchAnnouncementsEntry(entryId);

String content = BeanParamUtil.getString(entry, request, "content");

User currentUser = UserLocalServiceUtil.getUserById(themeDisplay.getUserId());
%>

<aui:form method="post" name='<%= renderResponse.getNamespace() + "fm" %>' onSubmit='<%= "event.preventDefault(); " + renderResponse.getNamespace() + "saveEntry();" %>' useNamespace="false">
	<aui:input name="<%= Constants.CMD %>" type="hidden" value="<%= (entry == null) ? Constants.ADD : Constants.UPDATE %>" />
	<aui:input name="redirect" type="hidden" value="<%= redirect %>" />
	<aui:input name="entryId" type="hidden" value="<%= entryId %>" />
	<aui:input name="alert" type="hidden" value="<%= portletName.equals(PortletKeys.ALERTS) %>" />

	<aui:model-context bean="<%= entry %>" model="<%= AnnouncementsEntry.class %>" />

	<aui:fieldset>
		<c:choose>
			<c:when test="<%= entry != null %>">

				<%
				boolean showScopeName = true;
				%>

				<%@ include file="/entry_scope.jspf" %>

			</c:when>
			<c:otherwise>

				<%
				String distributionScope = ParamUtil.getString(request, "distributionScope");

				long classNameId = -1;
				long classPK = -1;

				String[] distributionScopeArray = StringUtil.split(distributionScope);

				if (distributionScopeArray.length == 2) {
					classNameId = GetterUtil.getLong(distributionScopeArray[0]);
					classPK = GetterUtil.getLong(distributionScopeArray[1]);
				}

				boolean submitOnChange = false;
				%>

				<%@ include file="/entry_select_scope.jspf" %>

			</c:otherwise>
		</c:choose>

		<aui:select cssClass="type" name="type">

			<%
			for (String curType : AnnouncementsEntryConstants.TYPES) {
			%>

			<aui:option label="<%= curType %>" />

			<%
			}
			%>

		</aui:select>

		<aui:select cssClass="priority" name="priority">
			<aui:option label="normal" value="0" />
			<aui:option label="important" value="1" />
		</aui:select>

		<aui:input name="title" />

		<aui:input name="url" />

		<aui:field-wrapper label="content">
			<liferay-ui:input-editor height="150" toolbarSet="Basic" width="100%" />

			<aui:input name="content" type="hidden" />
		</aui:field-wrapper>

		<aui:input name="displayDate" />

		<aui:input name="expirationDate" />
	</aui:fieldset>

	<aui:button-row>
		<aui:button type="submit" />

		<aui:button onClick='<%= renderResponse.getNamespace() + "previewEntry();" %>' value="preview" />

		<aui:button href="<%= redirect %>" type="cancel" />
	</aui:button-row>

</aui:form>
<div id="<%= renderResponse.getNamespace() + "preview" %>"></div>

<aui:script>
	function <portlet:namespace />getContent() {
		return window.editor.getHTML();
	}

	function initEditor() {
		var ckEditor = CKEDITOR.instances["editor"];
		ckEditor.resize("100%", "200");

		return "<%= UnicodeFormatter.toString(content) %>";
	}

	function <portlet:namespace />previewEntry() {
		var A = AUI();

		if (A.one('select[name="distributionScope"]') !== null) {
			optValue = A.one('select[name="distributionScope"]').get('value');
			scope = A.one('option[value=' + optValue + ']').get('text');
		}
		else {
			scope = "blank";
		}

		var date = new Date();

		var content = window.editor.getHTML();

		var preview = document.getElementById('<portlet:namespace />preview');
		preview.innerHTML="<div class='user-portrait'>"
				+ "<span class='avatar'>"
					+ "<a href='<%= currentUser.getDisplayURL(themeDisplay) %>'>"
						+ "<img alt='<%= currentUser.getFullName() %>' src='<%= currentUser.getPortraitURL(themeDisplay) %>' />"
					+ "</a>"
				+ "</span>"
			+ "</div>"
		+ "<div class='entry-data'>"
			+ "<div class='entry-header'>"
				+ "<div class='entry-time'>"
					+ date.toDateString()
				+ "</div>"
				+ "<div class='entry-user-name'>"
					+ themeDisplay.getUserName() + " to " + scope
				+ "</div>"
			+ "</div>"
			+ "<div class='entry-body'>"
				+ "<div class='title'>"
					+ A.one('#title').get('value')
				+ "</div>"
				+ "<div class='entry-content-container'>"
					+ "<div class='entry-content'>"
							+ content
					+ "</div>"
				+ "</div>"
			+ "</div>"
			+ "<div class='entry-footer'>"
				+ "<div class='entry-footer-toolbar'>"
					+ "<span class='action' id='toggle-entryPreview'></span>"
				+ "</div>"
			+ "</div>"
		+ "</div>";

		var previewContent = A.one('#<portlet:namespace />preview .entry-content');

		if (previewContent.height() > 75) {
			var toggleEntry = document.getElementById('toggle-entryPreview');
			toggleEntry.innerHTML='<a class="toggle-entry" data-entryId="preview" href="javascript:;"><liferay-ui:message key='view-more' /></a>';
		}
	}

	function <portlet:namespace />saveEntry() {
		document.<portlet:namespace />fm.target = '';
		document.<portlet:namespace />fm.<%= Constants.CMD %>.value = "<%= (entry == null) ? Constants.ADD : Constants.UPDATE %>";
		document.<portlet:namespace />fm.content.value = <portlet:namespace />getContent();
		submitForm(document.<portlet:namespace />fm, "<liferay-portlet:actionURL portletName="<%= PortletKeys.ANNOUNCEMENTS %>"><portlet:param name="struts_action" value="/announcements/edit_entry" /></liferay-portlet:actionURL>");
	}
</aui:script>
<aui:script use="aui-base,transition">
	var announcementEntries = A.one('#main-content');

	announcementEntries.delegate(
		'click',
		function(event) {
			var node = event.currentTarget;
			entryId = node.getAttribute('data-entryId');

			var entry = A.one('#<portlet:namespace />' + entryId);
			var content = entry.one('.entry-content');
			var contentContainer = entry.one('.entry-content-container');
			var control = entry.all('.toggle-entry');
			contentHeight = '75px';

			if (entry.hasClass('visible')) {
				entry.removeClass('visible');

				contentHeight = '75px';

				if (control) {
					control.html('<%= UnicodeLanguageUtil.get(pageContext, "view-more") %>');
				}
			}
			else {
				entry.addClass('visible');

				contentHeight = content.getComputedStyle('height');

				if (control) {
					control.html('<%= UnicodeLanguageUtil.get(pageContext, "view-less") %>');
				}
			}
			contentContainer.transition(
				{
					height: contentHeight,
					duration: 0.5,
					easing: 'ease-in-out'
				}
			);
		},
		'.toggle-entry'
	);
</aui:script>