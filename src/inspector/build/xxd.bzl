## Copyright 2018 The Chromium Authors. All rights reserved.
## Use of this source code is governed by a BSD-style license that can be
## found in the LICENSE file.

def _xxd_impl(ctx):
    output = ctx.actions.declare_file(ctx.attr.output)
    ctx.actions.run(
        outputs = [output],
        inputs = [ctx.file.src],
        arguments = [
            ctx.attr.var,
            ctx.file.src.path,
            output.path,
        ],
        executable = ctx.executable._xxd,
    )

    return [
        DefaultInfo(
            files = depset([output]),
        ),
    ]


xxd = rule(
    implementation = _xxd_impl,
    attrs = {
        "src": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        "var": attr.string(
            mandatory = True,
        ),
        "output": attr.string(
            mandatory = True,
        ),
        "_xxd": attr.label(
            default = Label("//src/inspector/build:xxd"),
            executable = True,
            cfg = "host",
        ),
    },
)
