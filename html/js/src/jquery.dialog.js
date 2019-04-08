/* 
	
The MIT License (MIT)

Copyright (c) 2017 Etienne Martin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

"use strict";

(function ($) {

	window.dialog = {
		defaultParams: {
			title: "",
			message: "",
			button: "Ok",
			cancel: "Cancel",
			item: "",
			type: "",
			required: false,
			select: false,
			position: "fixed",
			animation: "scale",
			input: {
				type: "text"
			},
			validate: function (value, item, type) { },
			callback: function (value) { }
		},
		transitionEnd: "transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd",
		alert: function (params) {

			dialog.appendDialogHolder();

			var params = $.extend(true, {}, dialog.defaultParams, params);
			var alertId = dialog.generateRandomId();

			var newAlert = '<div class="dialog-alert" id="' + alertId + '">';
			newAlert += '<div class="dialog-border"></div>';
			newAlert += '<div class="dialog-title">' + params.title + '</div>';
			newAlert += '<div class="dialog-message">' + params.message + '</div>';
			newAlert += '<div class="dialog-close">&times;</div>';
			newAlert += '<div class="dialog-confirm">' + params.button + '</div>';
			newAlert += '<div class="dialog-clearFloat"></div>';
			newAlert += '</div>';

			dialog.holder.find("td").append(newAlert);

			var alert = $("#" + alertId);
			var confirm = alert.find(".dialog-confirm");
			var close = alert.find(".dialog-close");

			if (params.required === true) {
				close.remove();
			}

			alert.attr("data-dialog-position", params.position);
			alert.attr("data-dialog-animation", params.animation);

			dialog.injectDialog();

			confirm.one("click.dialog", function () {
				params.callback(true);
			});
			close.one("click.dialog", function () {
				params.callback(null);
			});
		},
		prompt: function (params) {

			dialog.appendDialogHolder();

			var params = $.extend(true, {}, dialog.defaultParams, params);
			var alertId = dialog.generateRandomId();

			var inputAttributes = "";
			for (var attribute in params.input) {
				inputAttributes += ' ' + attribute + '="' + params.input[attribute] + '" ';
			}

			var newAlert = '<div class="dialog-alert" id="' + alertId + '">';
			newAlert += '<div class="dialog-border"></div>';
			newAlert += '<div class="dialog-title">' + params.title + '</div>';
			newAlert += '<div class="dialog-message">' + params.message + '</div>';
			if (params.select) {
				params.item.players.forEach(function (player) {
					newAlert += '<div class="select" data-player="' + player.player + '">' + player.label + '</div>';
				});
			} else {
				newAlert += '<label><input ' + inputAttributes + ' /></label>';
			}
			newAlert += '<div class="dialog-close">&times;</div>';

			if (!params.select) {
				newAlert += '<div class="dialog-confirm">' + params.button + '</div>';
			}

			newAlert += '<div class="dialog-clearFloat"></div>';
			newAlert += '</div>';

			dialog.holder.find("td").append(newAlert);

			var alert = $("#" + alertId);
			if (!params.select) {
				var confirm = alert.find(".dialog-confirm");
			} else {
				var confirm = alert.find(".select");
			}
			var close = alert.find(".dialog-close");
			var input = alert.find("input");

			if (params.required === true) {
				close.remove();
			}

			alert.attr("data-dialog-position", params.position);
			alert.attr("data-dialog-animation", params.animation);

			dialog.injectDialog();

			confirm.bind("click.dialog", function () {
				var value = input.val();
				if (!params.select) {
					var isValid = params.validate(value, params.item, params.type) === false ? false : true;
				} else {
					var isValid = params.validate(value, params.item, $(this).data("player")) === false ? false : true;
				}

				if (params.required === true && value === "") {
					isValid = false;
				}

				if (!isValid) {
					alert.one("webkitAnimationEnd oanimationend msAnimationEnd animationend", function (e) {
						alert.removeClass("dialog-shaking");
					}).addClass("dialog-shaking");

					return false;
				}
				params.callback(value);
			});
			close.one("click.dialog", function () {
				params.callback(null);
			});
		},
		confirm: function (params) {

			dialog.appendDialogHolder();

			var params = $.extend(true, {}, dialog.defaultParams, params);
			var alertId = dialog.generateRandomId();

			var newAlert = '<div class="dialog-alert" id="' + alertId + '">';
			newAlert += '<div class="dialog-border"></div>';
			newAlert += '<div class="dialog-title">' + params.title + '</div>';
			newAlert += '<div class="dialog-message">' + params.message + '</div>';
			newAlert += '<div class="dialog-close">&times;</div>';
			newAlert += '<div class="dialog-cancel">' + params.cancel + '</div>';
			newAlert += '<div class="dialog-confirm">' + params.button + '</div>';
			newAlert += '<div class="dialog-clearFloat"></div>';
			newAlert += '</div>';

			dialog.holder.find("td").append(newAlert);

			var alert = $("#" + alertId);
			var confirm = alert.find(".dialog-confirm");
			var cancel = alert.find(".dialog-cancel");
			var close = alert.find(".dialog-close");

			if (params.required === true) {
				close.remove();
			}

			alert.attr("data-dialog-position", params.position);
			alert.attr("data-dialog-animation", params.animation);

			dialog.injectDialog();

			confirm.one("click.dialog", function () {
				params.callback(true);
			});
			cancel.one("click.dialog", function () {
				params.callback(false);
			});
			close.one("click.dialog", function () {
				params.callback(null);
			});
		},
		generateRandomId: function () {
			return (Math.floor(Math.random() * 1000000) + 1) + new Date().getTime();
		},
		showDialog: function () {

			$(":focus").blur();

			var firstAlert = $(".dialog-alert:first");

			if (firstAlert.attr("data-dialog-position") === "absolute") {
				dialog.holder.removeClass("dialog-fixed");
				dialog.holder.css("top", $(window).scrollTop());
			} else {
				dialog.holder.addClass("dialog-fixed");
				dialog.holder.css("top", "");
			}

			$(window).trigger("resize.dialog");

			$(".dialog-alert").hide();

			firstAlert.show();

			setTimeout(function () {
				firstAlert.bind(dialog.transitionEnd, function (e) {

					// Make sure that the event was fired for the alert and not its content.
					if (!$(e.target).is(this)) {
						return;
					}
					firstAlert.unbind(dialog.transitionEnd);

					dialog.focusElement(firstAlert.find("input")[0], true);
				}).addClass("dialog-visible");
			}, 1);

			$("html").addClass("dialogIsVisible");

		},
		injectDialog: function () {
			if ($(".dialog-alert:visible").length === 0) {
				dialog.showDialog();
			} else {
				$(".dialog-alert:last").hide();
			}
			dialog.overlay.addClass("dialog-visible");
		},
		focusElement: function (elem, moveCursorToEnd) {

			if (!elem) {
				return;
			}

			$(elem).one("blur.dialog", function () {
				dialog.focusElement(elem, false);
			})

			// Focus the input
			elem.focus();

			if (moveCursorToEnd) {
				// Scroll to the very right of the input
				elem.scrollLeft = elem.scrollWidth;
			}
		},
		appendDialogHolder: function () {

			if (dialog.holder) {
				return;
			}

			$("body").append('<div id="dialog-overlay"></div><div id="dialog-holder"><table id="dialog-center"><tr><td></td></tr></table></div>');
			dialog.overlay = $("#dialog-overlay");
			dialog.holder = $("#dialog-holder");

			dialog.bindDialogGlobalEvents();

			$("html").addClass("dialogHolderIsVisible");

		},
		removeDialogHolder: function () {

			dialog.unbindDialogGlobalEvents();

			dialog.overlay.remove();
			dialog.holder.remove();

			dialog.overlay = undefined;
			dialog.holder = undefined;

			$("html").removeClass("dialogHolderIsVisible");

		},
		close: function () {
			var alert = $(".dialog-alert:not(.dialog-closing):first");

			alert.addClass("dialog-closing").bind(dialog.transitionEnd, function (e) {

				// Make sure that the event was fired for the alert and not its content.
				if (!$(e.target).is(this)) {
					return;
				}
				alert.unbind(dialog.transitionEnd);

				alert.remove();

				$("html").removeClass("dialogIsVisible");

				if ($(".dialog-alert").length === 0) {
					dialog.overlay.addClass("dialog-closing").bind(dialog.transitionEnd, function (e) {

						// Make sure that the event was fired for the alert and not its content.
						if (!$(e.target).is(this)) {
							return;
						}
						dialog.overlay.unbind(dialog.transitionEnd);

						dialog.removeDialogHolder();
					}).removeClass("dialog-visible");
				} else {
					dialog.showDialog();
				}
			}).removeClass("dialog-visible");

		},
		bindDialogGlobalEvents: function () {

			dialog.holder.add(dialog.overlay).bind("click.dialog", function (e) {
				if (!$(e.target).closest(".dialog-alert").is(".dialog-alert")) {
					$(".dialog-close:visible").trigger("click");
				}
			});

			$(document).on("click.dialog", ".dialog-confirm, .dialog-cancel, .dialog-close, .select", function (event) {
				dialog.close();
				return false;
			});

			$(document).bind("keyup.dialog", function (e) {
				if (e.keyCode == 27 && $(".dialog-alert").is(":visible")) { // Esc key
					$(".dialog-close:visible").trigger("click");
				}
			});

			$(document).bind("keydown.dialog", function (event) {

				var alert = $(".dialog-alert:visible");

				if (alert.length === 0) {
					return;
				}

				if (event.keyCode == 13) { // Enter key
					alert.find(".dialog-confirm").trigger("click");
					return false;
				}
			});

			$(window).bind("resize.dialog", function () {
				dialog.overlay.height("100%");
				dialog.overlay.height($(document).height());
			});
		},
		unbindDialogGlobalEvents: function () {
			dialog.overlay.off(".dialog");
			dialog.holder.off(".dialog");
			$(document).off(".dialog");
			$(window).off(".dialog");
		}
	};

})(jQuery);
