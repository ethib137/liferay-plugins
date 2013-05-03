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
portletURL.setParameter("mvcPath", "/view.jsp");

LinkedHashMap<Long, long[]> scopes = AnnouncementsUtil.getAnnouncementScopes(user.getUserId());

scopes.put(new Long(0), new long[] {0});

int flagValue = AnnouncementsFlagConstants.NOT_HIDDEN;

PortletPreferences preferences = renderRequest.getPreferences();

String portletResource = ParamUtil.getString(request, "portletResource");

if (Validator.isNotNull(portletResource)) {
	preferences = PortletPreferencesFactoryUtil.getPortletSetup(request, portletResource);
}

int pageDelta = GetterUtil.getInteger(preferences.getValue("pageDelta", String.valueOf(SearchContainer.DEFAULT_DELTA)));

SearchContainer searchContainer = new SearchContainer(renderRequest, null, null, "cur1", pageDelta, portletURL, null, "there-are-currently-no-unread-entries");

List<AnnouncementsEntry> results = null;

int total = 0;
%>

<c:if test="<%= permissionChecker.isGroupAdmin(layout.getGroupId()) || permissionChecker.isGroupOwner(layout.getGroupId()) %>">
	<div class="admin-actions">
		<aui:button onClick='<%= renderResponse.getNamespace() + "addEntry()" %>' value="add-entry" />
		<aui:button onClick='<%= renderResponse.getNamespace() + "manageEntries()" %>' value="manage-entries" />
	</div>
</c:if>

<div class="unread-entries" id="unreadEntries">
	<%@ include file="/entry_iterator.jspf" %>
</div>

<%
int visibleMessagesCount = total;
%>

<c:if test="<%= visibleMessagesCount > 0 %>">
	<liferay-ui:search-paginator id="pageIteratorTop" searchContainer="<%= searchContainer %>" type="article" />
</c:if>

<%
flagValue = AnnouncementsFlagConstants.HIDDEN;

searchContainer = new SearchContainer(renderRequest, null, null, "cur2", pageDelta, portletURL, null, "there-are-currently-no-read-entries");
%>

<c:if test="<%= themeDisplay.isSignedIn() %>">
	<div class="read-entries" id="readEntries">
		<div class="header">
			<span><%= LanguageUtil.get(pageContext, "read-entries") %></span>
		</div>
		<div class="content">
			<%@ include file="/entry_iterator.jspf" %>
		</div>
	</div>
</c:if>

<%
int hiddenMessagesCount = total;

String distributionScope = ParamUtil.getString(request, "distributionScope");
%>

<c:if test="<%= hiddenMessagesCount > 0 %>">
	<liferay-ui:search-paginator id="pageIteratorBottom" searchContainer="<%= searchContainer %>" type="article" />
</c:if>

<aui:script use="aui-base,transition">
	var announcementEntries = A.one('#p_p_id_1_WAR_soannouncementsportlet_');

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

<aui:script>
	function <portlet:namespace />handleEntry(entryId) {
		var A = AUI();

		var entry = A.one('#<portlet:namespace />' + entryId);

		if (entry) {
			var container = entry.get('parentNode');

			if (container) {
				if (container.hasClass('unread-entries')) {
					<portlet:namespace />markEntry(entry, entryId);
				}
				else {
					<portlet:namespace />unmarkEntry(entry, entryId);
				}
			}
		}
	}

	function <portlet:namespace />markEntry(entry, entryId) {
		var A = AUI();

		Liferay.Service.Announcements.AnnouncementsFlag.addFlag({entryId : entryId, flag: <%= AnnouncementsFlagConstants.HIDDEN %>});

		Liferay.Portlet.refresh('#p_p_id<portlet:namespace />');
	}

	function <portlet:namespace />unmarkEntry(entry, entryId) {
		var A = AUI();

		flag = Liferay.Service.Announcements.AnnouncementsFlag.getFlag({entryId : entryId, flag: <%= AnnouncementsFlagConstants.HIDDEN %>});

		Liferay.Service.Announcements.AnnouncementsFlag.deleteFlag({flag: flag.flagId});

		Liferay.Portlet.refresh('#p_p_id<portlet:namespace />');
	}

	YUI().ready(
	'aui-toggler',
		function(Y) {
			new Y.Toggler(
				{
				animated: true,
				container: '#readEntries',
				content: '.content',
				expanded: false,
				header: '.header',
				transition: {
					duration: 0.5,
					easing: 'ease-in-out'
					}
				}
			);
		}
	);

	function <portlet:namespace />addEntry() {
		<portlet:renderURL var="addEntryURL" windowState="<%= LiferayWindowState.POP_UP.toString() %>"><portlet:param name="mvcPath" value="/edit_entry.jsp" /><portlet:param name="redirect" value="<%= currentURL %>" /></portlet:renderURL>

		<portlet:namespace />openPopup('<%= LanguageUtil.get(pageContext, "add-entry") %>', 500, 'so-portlet-announcements-edit-dialog', '<%= addEntryURL %>')
	}

	function <portlet:namespace />manageEntries() {
		<portlet:renderURL var="manageEntriesURL" windowState="<%= LiferayWindowState.POP_UP.toString() %>"><portlet:param name="mvcPath" value="/manage_entries.jsp" /></portlet:renderURL>

		<portlet:namespace />openWindow('<%= manageEntriesURL %>', '<%= LanguageUtil.get(pageContext, "manage-entries") %>', true, 800);
	}

	function <portlet:namespace />editEntry(uri) {
		<portlet:namespace />openPopup('<%= LanguageUtil.get(pageContext, "edit-entry") %>', 500, 'so-portlet-announcements-edit-dialog', uri);
	}

	function <portlet:namespace />openPopup(title, width, cssClass, url) {
		var A = AUI();
		var dialog = new A.Dialog(
			{
				align: Liferay.Util.Window.ALIGN_CENTER,
				cssClass: cssClass,
				modal: true,
				resizable: true,
				title: title,
				width: width
			}
		).plug(
			A.Plugin.IO,
			{
				autoLoad: false,
				uri: url
			}
		).render();

		dialog.show();
		dialog.io.start();
	}

	function <portlet:namespace />openWindow(url, title, modal, width) {
		Liferay.Util.openWindow(
			{
				dialog: {
					align: Liferay.Util.Window.ALIGN_CENTER,
					modal: modal,
					width: width
				},
				title: title,
				uri: url
			}
		);
	}
</aui:script>