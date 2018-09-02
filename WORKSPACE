## Copyright 2018 The Chromium Authors. All rights reserved.
## Use of this source code is governed by a BSD-style license that can be
## found in the LICENSE file.

workspace(name = "org_chromium_v8")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

# TODO(yannic): Change to local_repository(base/trace_event/common)
# and let gclient handle syncs.
git_repository(
    name = "org_chromium_base_trace_event_common",
    remote = "https://github.com/YBApp-Bot/org_chromium_base_trace_event_common.git",
    commit = "5564106f6b0b21e3f472c4e141de930c52eb9810",
)

# TODO(yannic): Change to local_repository(v8/third_party/googletest/src)
# and let gclient handle syncs.
git_repository(
    name = "com_google_googletest",
    remote = "https://github.com/google/googletest.git",
    commit = "2e68926a9d4929e9289373cd49e40ddcb9a628f7",
)
