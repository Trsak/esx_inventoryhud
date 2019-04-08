/****************************************
 *  jQuery 上下文菜单插件，支持多级菜单和图标显示，
 *  自定义样式实现灵活控制菜单风格
 *
 *  在 MTI 许可下，可自由分发、修改、复制该代码。
 *  可以在你的项目（不限于商业盈利性项目）下免费
 *  使用源码
 *
 *  @copyright jhoneleeo@gmail.com
 *  @version 1.0.0
 *  Date: 2017-3-5
 ****************************************/
(function ($) {
    /**
     * 为对象绑定上下文菜单方法
     * @function contextMenu
     * @param {Object} data 菜单数据。由text、items、action组成的对象数组
     * @param {Object} options 配置参数
     */
    $.fn.contextMenu = function (data, options) {

        var $body = $("body"),
            defaults = {
                name: "",  // 字符串。上下文菜单的名称，用以区分不同的上下文菜单。如果缺省，插件将自动分配名称
                offsetX: 15, // 数值。上下文菜单左上角距离鼠标水平偏移距离
                offsetY: 5, // 数值。上下文菜单左上角距离鼠标垂直偏移距离
                beforeShow: $.noop, // 函数。菜单即将显示之前执行的回调函数
                afterShow: $.noop // 函数。菜单显示后执行的回调函数
            };

        var params = $.extend(defaults, options || {}), keyMap = {},
            idKey = "site_cm_", classKey = "site-cm-",
            name = name || ("JCM_" + +new Date() + (Math.floor(Math.random() * 1000) + 1)),
            count = 0;

        /**
         * 构建菜单HTML
         * @param {*} mdata 菜单数据，如果没有菜单数据以data数据为准
         */
        var buildMenuHtml = function (mdata) {
                // 菜单数据
                var menuData = mdata || data,
                    idName = idKey + (mdata ? count++ : name),
                    className = classKey + "box";

                var $mbox = $('<div id="' + idName + '" class="' + className + '" style="position:absolute; display: none;">');

                $.each(menuData, function (index, group) {
                    if (!$.isArray(group)) {
                        throw TypeError();
                    }
                    index && $mbox.append('<div class="' + classKey + 'separ">');
                    if (!group.length) {
                        return;
                    }
                    var $ul = $('<ul class="' + classKey + 'group">');
                    // 循环遍历每组菜单
                    $.each(group, function (innerIndex, item) {
                        // 需要检测菜单项目是否包含子菜单
                        var key, $li = $("<li>" + item.text + ($.isArray(item.items) && item.items.length ? buildMenuHtml(item.items) : "") + "</li>");
                        $.isFunction(item.action) && (key = (name + "_" + count + "_" + index + "_" + innerIndex), keyMap[key] = item.action, $li.attr("data-key", key));
                        $ul.append($li).appendTo($mbox);
                    });
                });
                var html = $mbox.get(0).outerHTML;
                $mbox = null;
                return html;
            },
            // 创建上下文菜单
            createContextMenu = function () {
                var $menu = $("#" + idKey + name);
                if (!$menu.length) {
                    var html = buildMenuHtml();
                    $menu = $(html).appendTo($body);
                    $("li", $menu).on("mouseover", function () {
                        $(this).addClass("hover").children("." + classKey + "box").show();
                    }).on("mouseout", function () {
                        $(this).removeClass("hover").children("." + classKey + "box").hide();
                    }).on("click", function () {
                        var key = $(this).data("key");
                        key && (keyMap[key].call(this) !== false) && $menu.hide();  // 调用执行函数
                    });
                    $menu.on("contextmenu", function () {
                        return false;
                    });
                }
                return $menu;
            };

        $body.on("mousedown", function (e) {
            var jid = ("#" + idKey + name);
            !$(e.target).closest(jid).length && $(jid).hide();
        });

        return this.each(function () {
            $(this).on("contextmenu", function (e) {

                if ($.isFunction(params.beforeShow) && params.beforeShow.call(this, e) === false) {
                    return;
                }

                e.cancelBubble = true;
                e.preventDefault();

                var $menu = createContextMenu();
                $menu.show().offset({left: e.clientX + params.offsetX, top: e.clientY + params.offsetY});

                $.isFunction(params.afterShow) && params.afterShow.call(this, e)
            });
        });
    };
})(jQuery);
