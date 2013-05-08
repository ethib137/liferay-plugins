AUI().use(
	'aui-base',
	'aui-dialog',
	'aui-io-plugin',
	'transition',
	function(A) {
		Liferay.namespace('Announcements');

		Liferay.Announcements = {
			openPopup: function(title, width, cssClass, url) {
				var popup = new A.Dialog(
					{
						align: Liferay.Util.Window.ALIGN_CENTER,
						cssClass: cssClass,
						draggable: true,
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

				popup.show();
				popup.io.start();
			},

			toggleEntry: function(event, portletNamespace) {
				var node = event.currentTarget;
				var entryId = node.getAttribute('data-entryId');
				var entry = A.one('#' + portletNamespace + entryId);
				var content = entry.one('.entry-content');
				var contentContainer = entry.one('.entry-content-container');
				var control = entry.all('.toggle-entry');

				contentHeight = '75px';

				if (entry.hasClass('visible')) {
					entry.removeClass('visible');

					contentHeight = '75px';

					if (control) {
						control.html(Liferay.Language.get('view-more'));
					}
				}
				else {
					entry.addClass('visible');

					contentHeight = content.getComputedStyle('height');

					if (control) {
						control.html(Liferay.Language.get('view-less'));
					}
				}
				contentContainer.transition(
					{
						height: contentHeight,
						duration: 0.5,
						easing: 'ease-in-out'
					}
				);
			}
		};
	}
);