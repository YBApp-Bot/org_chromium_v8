## Copyright 2018 The Chromium Authors. All rights reserved.
## Use of this source code is governed by a BSD-style license that can be
## found in the LICENSE file.

_TorqueCore = provider()
_TorqueInitializers = provider()


def _dirname(file):
    # TODO(yannic): This may not work on windows.
    return file[:file.rfind("/")]


def _torque_impl(ctx):
    outputs = [ctx.actions.declare_file("builtin-definitions-from-dsl.h")]
    for module in ctx.attr.modules:
        outputs += [
            ctx.actions.declare_file(
                "builtins-{}-from-dsl-gen.cc".format(module)),
            ctx.actions.declare_file(
                "builtins-{}-from-dsl-gen.h".format(module)),
        ]

    args = ["-o", _dirname(outputs[0].path)] + [f.path for f in ctx.files.srcs]
    ctx.actions.run(
        outputs = outputs,
        inputs = ctx.files.srcs,
        arguments = args,
        executable = ctx.executable._torque,
    )

    return [
        _TorqueCore(
            # Only |builtin-definitions-from-dsl.h|.
            files = depset([outputs[0]]),
        ),
        _TorqueInitializers(
            # Except |builtin-definitions-from-dsl.h|.
            files = depset(outputs[1:]),
        ),
    ]

torque = rule(
    implementation = _torque_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = [".tq"],
        ),
        "modules": attr.string_list(
            mandatory = True,
        ),
        "_torque": attr.label(
            default = Label("//:torque"),
            executable = True,
            cfg = "host",
        ),
    },
)


def _torque_core_impl(ctx):
    return [
        DefaultInfo(
            files = ctx.attr.torque[_TorqueCore].files,
        ),
    ]

torque_core = rule(
    implementation = _torque_core_impl,
    attrs = {
        "torque": attr.label(
            mandatory = True,
            providers = [_TorqueCore],
        ),
    },
)


def _torque_initializers_impl(ctx):
    return [
        DefaultInfo(
            files = ctx.attr.torque[_TorqueInitializers].files,
        ),
    ]

torque_initializers = rule(
    implementation = _torque_initializers_impl,
    attrs = {
        "torque": attr.label(
            mandatory = True,
            providers = [_TorqueInitializers],
        ),
    },
)
