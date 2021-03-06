{extend name="base/common"}
{block name="pre_head"}
    <script src="__STATIC__/libs/editor.md/lib/raphael.min.js"></script>
{/block}
{block name="style"}
    <link rel="stylesheet" href="__STATIC__/libs/editor.md/css/editormd.min.css">
{/block}
{block name="category"}{/block}


{block name="body"}
    <div class="post-box animated animated-quick slideInUp">
        <form id="post_form" action="" method="post">
            <input type="hidden" name="id" value="{$data.id}" class="hidden">
            <div class="form-group row" style="margin: 20px;">
                <h3 class="text-center">{$data.post.title}（回复）</h3>
            </div>
            <div class="form-group">
                <div class="" id="post_content">
                    <textarea class="editormd-markdown-textarea"
                              name="md_content">{$data.md_content}</textarea>
                    <textarea class="editormd-html-textarea" name="content"></textarea>
                </div>
            </div>
            <div class="form-group text-center">
                <button type="submit" class="btn btn-success btn-lg">确认修改</button>
            </div>
        </form>
    </div>
    <script>
        seajs.use(['editormd', 'editorTools'], function (editormd, Edtools) {
            var editor = editormd({
                id: "post_content",
                height: 640,
                path: "/static/libs/editor.md/lib/",
                toolbarIcons: function () {
                    // Or return editormd.toolbarModes[name]; // full, simple, mini
                    // Using "||" set icons align right.
                    return ["undo", "redo", "|", "bold", "hr", "|", "preview", "watch", "|", "fullscreen", "info", "testIcon", "testIcon2", "file", "faicon", "||", "watch", "fullscreen", "preview", "testIcon"]
                },
                //toolbar  : false,             // 关闭工具栏
                codeFold: true,
                placeholder: '文明上网,理性发言....',
                searchReplace: true,
                saveHTMLToTextarea: true,      // 保存 HTML 到 Textarea
                htmlDecode: "style,script,iframe|on*",            // 开启 HTML 标签解析，为了安全性，默认不开启
                emoji: false,
                taskList: true,
                tocm: true,          // Using [TOCM]
                tex: false,                      // 开启科学公式 TeX 语言支持，默认关闭
                //previewCodeHighlight : false,  // 关闭预览窗口的代码高亮，默认开启
                flowChart: false,                // 疑似 Sea.js与 Raphael.js 有冲突，必须先加载 Raphael.js ，Editor.md 才能在 Sea.js 下正常进行；
                sequenceDiagram: true         // 同上
            });

            //上传图片
            Edtools.paste("#post_content", function (base64, image, event) {
                $.post("{:url('api/uploader/upEditorImg')}",{base:base64}, function (ret) {
                    layer.msg(ret.msg);
                    if (ret.code === 1) {
                        //新一行的图片显示
                        editor.insertValue("\n![" + ret.data.title + "](" + ret.data.path + ")");
                    }
                });
            });

            Edtools.drag("#post_content", function (base64, image, event) {
                $.post("{:url('api/uploader/upEditorImg')}",{base:base64}, function (ret) {
                    layer.msg(ret.msg);
                    if (ret.code === 1) {
                        //新一行的图片显示
                        editor.insertValue("\n![" + ret.data.title + "](" + ret.data.path + ")");
                    }
                });
            });
        });

        seajs.use(['layer'], function () {

            //验证码
            $(".post-verify-img").click(function (e) {
                e.preventDefault();
                var $this = $(this);
                $this.attr('src', "{:url('portal/getPostVerify')}?v=" + Math.random());
            });
            //

            $('#post_form').submit(function (e) {
                e.preventDefault();
                var $this = $(this);
                $.post($this.attr('action'), $this.serialize(), function (ret) {
                    layer.msg(ret.msg);
                    $(".post-verify-img").trigger('click');
                });
            });

            //验证码
            $('.auth-verify-img').click(function (e) {
                e.preventDefault();
                var $this = $(this);
                $this.attr('src', "{:url('portal/getVerify')}?v=" + Math.random());
            });

        });
    </script>
{/block}