## Copyright 2018 The Chromium Authors. All rights reserved.
## Use of this source code is governed by a BSD-style license that can be
## found in the LICENSE file.

load(":check_protocol_compatibility.bzl", _ProtocolCompatibilityInfo = "ProtocolCompatibilityInfo")

_protocol_generated = [
    "gen/src/inspector/protocol/Forward.h",
    "gen/src/inspector/protocol/Protocol.cpp",
    "gen/src/inspector/protocol/Protocol.h",
    "gen/src/inspector/protocol/Console.cpp",
    "gen/src/inspector/protocol/Console.h",
    "gen/src/inspector/protocol/Debugger.cpp",
    "gen/src/inspector/protocol/Debugger.h",
    "gen/src/inspector/protocol/HeapProfiler.cpp",
    "gen/src/inspector/protocol/HeapProfiler.h",
    "gen/src/inspector/protocol/Profiler.cpp",
    "gen/src/inspector/protocol/Profiler.h",
    "gen/src/inspector/protocol/Runtime.cpp",
    "gen/src/inspector/protocol/Runtime.h",
    "gen/src/inspector/protocol/Schema.cpp",
    "gen/src/inspector/protocol/Schema.h",
    "gen/include/inspector/Debugger.h",
    "gen/include/inspector/Runtime.h",
    "gen/include/inspector/Schema.h",
]


def _output_base(file):
    # TODO(yannic): This may not work on windows.
    return "/".join(file.split("/")[:-2])


def _code_generator_impl(ctx):
    outputs = [ctx.actions.declare_file(f) for f in _protocol_generated]
    ctx.actions.run(
        outputs = outputs,
        inputs = [
            ctx.file.config,
            ctx.file.protocol,

            # While this file is not required, we still add it to inputs so that
            # bazel will execute the compatibility check.
            ctx.attr.compatibility[_ProtocolCompatibilityInfo].stamp,
        ],
        arguments = [
            # --jinja_dir is a noop for bazel build, but it is required to pass.
            "--jinja_dir",
            ".",

            "--output_base",
            _output_base(outputs[0].path),
            "--config",
            ctx.file.config.path,
        ],
        executable = ctx.executable._code_generator,
    )

    return [
        DefaultInfo(
            files = depset(outputs),
        ),
    ]


code_generator = rule(
    implementation = _code_generator_impl,
    attrs = {
        "config": attr.label(
            mandatory = True,
            allow_single_file = [".json"],
        ),
        "protocol": attr.label(
            mandatory = True,
            allow_single_file = [".json"],
        ),
        "compatibility": attr.label(
            mandatory = True,
            providers = [_ProtocolCompatibilityInfo],
        ),
        "_code_generator": attr.label(
            default = Label("//third_party/inspector_protocol:CodeGenerator"),
            executable = True,
            cfg = "host",
        ),
    },
)
