AUI().use(
	'aui-base',
	'aui-dialog',
	'aui-io-plugin',
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
			}
		};
	}
);