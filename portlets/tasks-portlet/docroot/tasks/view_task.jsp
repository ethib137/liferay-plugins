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
long tasksEntryId = ParamUtil.getLong(request, "tasksEntryId");

TasksEntry tasksEntry = TasksEntryLocalServiceUtil.fetchTasksEntry(tasksEntryId);
%>

<c:choose>
	<c:when test="<%= tasksEntry == null %>">
		<span class="alert alert-error"><liferay-ui:message key="task-could-not-be-found" /></span>
	</c:when>
	<c:otherwise>

		<%
		tasksEntry = tasksEntry.toEscapedModel();

		Calendar dueDate = CalendarFactoryUtil.getCalendar(timeZone, locale);
		%>

		<liferay-ui:header title="<%= HtmlUtil.unescape(tasksEntry.getTitle()) %>" />

		<div class="task-data-container">
			<div class="task-data assignee">
				<c:choose>
					<c:when test="<%= tasksEntry.getAssigneeUserId() > 0 %>">

						<%
						String assigneeDisplayURL = StringPool.BLANK;
						String taglibAssigneeDisplayURL = LanguageUtil.get(pageContext, "unknown-user");

						User assigneeUser = UserLocalServiceUtil.fetchUser(tasksEntry.getAssigneeUserId());

						if (assigneeUser != null) {
							assigneeDisplayURL = assigneeUser.getDisplayURL(themeDisplay);

							taglibAssigneeDisplayURL = "<a href=\"" + assigneeDisplayURL + "\">" + HtmlUtil.escape(tasksEntry.getAssigneeFullName()) + "</a>";
						}
						%>

						<liferay-ui:message arguments="<%= taglibAssigneeDisplayURL %>" key="assigned-to-x" translateArguments="<%= false %>" />
					</c:when>
					<c:otherwise>
						<liferay-ui:message key="unassigned" />
					</c:otherwise>
				</c:choose>
			</div>

			<div class="task-data reporter">

				<%
				String reporterDisplayURL = StringPool.BLANK;
				String taglibReporterDisplayURL = LanguageUtil.get(pageContext, "unknown-user");

				User reporterUser = UserLocalServiceUtil.fetchUser(tasksEntry.getUserId());

				if (reporterUser != null) {
					reporterDisplayURL = reporterUser.getDisplayURL(themeDisplay);

					taglibReporterDisplayURL = "<a href=\"" + reporterDisplayURL + "\">" + HtmlUtil.escape(tasksEntry.getReporterFullName()) + "</a>";
				}
				%>

				<liferay-ui:message arguments="<%= taglibReporterDisplayURL %>" key="created-by-x" translateArguments="<%= false %>" />
			</div>

			<div class="task-data last modified-date">
				<liferay-ui:message arguments="<%= dateFormatDateTime.format(tasksEntry.getModifiedDate()) %>" key="modified-on-x" translateArguments="<%= false %>" />
			</div>
		</div>

		<table class="task-data-table lfr-table">
		<tr>
			<td class="lfr-label">
				<liferay-ui:message key="status" />
			</td>
			<td>
				<div class="task-data status">
					<liferay-ui:message key="<%= tasksEntry.getStatusLabel() %>" />
				</div>
			</td>
		</tr>
		<tr>
			<td class="lfr-label">
				<liferay-ui:message key="priority" />
			</td>
			<td>
				<div class="task-data <%= tasksEntry.getPriorityLabel() %>">
					<liferay-ui:message key="<%= tasksEntry.getPriorityLabel() %>" />
				</div>
			</td>
		</tr>

		<c:if test="<%= tasksEntry.getDueDate() != null %>">
			<tr>
				<td class="lfr-label">
					<liferay-ui:message key="due-date" />
				</td>
				<td>
					<div class="task-data due-date">
						<%= dateFormatDateTime.format(tasksEntry.getDueDate()) %>
					</div>
				</td>
			</tr>
		</c:if>

		<tr>
			<td colspan="2">
				<br />
			</td>
		</tr>
		<tr>
			<td class="lfr-label">
				<liferay-ui:message key="tags" />
			</td>
			<td>
				<liferay-ui:asset-tags-summary
					className="<%= TasksEntry.class.getName() %>"
					classPK="<%= tasksEntry.getTasksEntryId() %>"
				/>
			</td>
		</tr>
		</table>

		<div class="task-action">
			<c:if test="<%= TasksEntryPermission.contains(permissionChecker, tasksEntry, ActionKeys.UPDATE) %>">

				<%
				boolean resolved = (tasksEntry.getStatus() == TasksEntryConstants.STATUS_RESOLVED);
				%>

				<input class="btn task-action-button" onClick="<portlet:namespace />updateStatus(<%= resolved ? TasksEntryConstants.STATUS_REOPENED : TasksEntryConstants.STATUS_RESOLVED %>)" type="button" value="<liferay-ui:message key='<%= resolved ? "reopen" : "resolve" %>' />" />

				<span class="task-action-spacer">
					<input class="btn" onClick="Liferay.Tasks.displayPopup('<portlet:renderURL windowState="<%= LiferayWindowState.EXCLUSIVE.toString() %>"><portlet:param name="mvcPath" value="/tasks/edit_task.jsp" /><portlet:param name="tasksEntryId" value="<%= String.valueOf(tasksEntry.getTasksEntryId()) %>" /></portlet:renderURL>', '<liferay-ui:message key="update-task" />');" type="button" value="<liferay-ui:message key="edit" />" />

					<input class="btn" onClick="if (confirm('<liferay-ui:message key="are-you-sure-you-want-to-delete-this-entry" />')){<portlet:namespace />deleteTask()}" type="button" value="<liferay-ui:message key="delete" />" />
				</span>

				<aui:script use="aui-io-deprecated">
					Liferay.provide(
						window,
						'<portlet:namespace />deleteTask',
						function() {
							A.io.request(
								'<portlet:actionURL name="deleteTasksEntry" />',
								{
									after: {
										success: function() {
											Liferay.Tasks.updateTaskList();

											Liferay.Tasks.closePopup();
										}
									},
									data: {
										<portlet:namespace />tasksEntryId: <%= tasksEntry.getTasksEntryId() %>
									}
								}
							);
						}
					);

					Liferay.provide(
						window,
						'<portlet:namespace />updateStatus',
						function(status) {
							A.io.request(
								'<portlet:actionURL name="updateTasksEntryStatus" />',
								{
									after: {
										success: function() {
											Liferay.Tasks.updateTaskList();

											Liferay.Tasks.displayPopup('<portlet:renderURL windowState="<%= LiferayWindowState.EXCLUSIVE.toString() %>"><portlet:param name="mvcPath" value="/tasks/view_task.jsp" /><portlet:param name="tasksEntryId" value="<%= String.valueOf(tasksEntry.getTasksEntryId()) %>" /></portlet:renderURL>', '<liferay-ui:message key="update-task" />');
										}
									},
									data: {
										<portlet:namespace />tasksEntryId: <%= tasksEntry.getTasksEntryId() %>,
										<portlet:namespace />resolverUserId: <%= user.getUserId() %>,
										<portlet:namespace />status: status
									}
								}
							);
						}
					);
				</aui:script>
			</c:if>

			<div class="task-action-right">
				<input class="btn" onClick="Liferay.Tasks.closePopup();" type="button" value="<liferay-ui:message key="close" />" />
			</div>
		</div>

		<liferay-ui:tabs names="comments" />

		<%@ include file="/tasks/view_comments.jspf" %>
	</c:otherwise>
</c:choose>