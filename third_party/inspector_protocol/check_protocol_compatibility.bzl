## Copyright 2018 The Chromium Authors. All rights reserved.
## Use of this source code is governed by a BSD-style license that can be
## found in the LICENSE file.

ProtocolCompatibilityInfo = provider()

def _check_protocol_compatibility_impl(ctx):
    stamp = ctx.actions.declare_file("{}.stamp".format(ctx.attr.name))
    ctx.actions.run(
        outputs = [stamp],
        inputs = [ctx.file.protocol],
        arguments = [
            "--stamp",
            stamp.path,
            ctx.file.protocol.path,
        ],
        executable = ctx.executable._check_protocol_compatibility,
    )

    return [
        ProtocolCompatibilityInfo(
            stamp = stamp,
        ),
    ]

check_protocol_compatibility = rule(
    implementation = _check_protocol_compatibility_impl,
    attrs = {
        "protocol": attr.label(
            mandatory = True,
            allow_single_file = [".json"],
        ),
        "_check_protocol_compatibility": attr.label(
            default = Label("//third_party/inspector_protocol:CheckProtocolCompatibility"),
            executable = True,
            cfg = "host",
        ),
    },
)
