## Copyright 2018 The Chromium Authors. All rights reserved.
## Use of this source code is governed by a BSD-style license that can be
## found in the LICENSE file.

workspace(name = "org_chromium_v8")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

# TODO(yannic): Change to local_repository(base/trace_event/common)
# and let gclient handle syncs.
git_repository(
    name = "org_chromium_base_trace_event_common",
    commit = "5564106f6b0b21e3f472c4e141de930c52eb9810",
    remote = "https://github.com/YBApp-Bot/org_chromium_base_trace_event_common.git",
)

# TODO(yannic): Change to local_repository(v8/third_party/googletest/src)
# and let gclient handle syncs.
git_repository(
    name = "com_google_googletest",
    commit = "2e68926a9d4929e9289373cd49e40ddcb9a628f7",
    remote = "https://github.com/google/googletest.git",
)

# TODO(yannic): Change to local_repository and let gclient handle syncs.
git_repository(
    name = "com_github_mitsuhiko_markupsafe",
    commit = "f725da845fcdb651d8d1b7e0b3e7e9fd4d459ebe",
    remote = "https://github.com/YBApp-Bot/com_github_mitsuhiko_markupsafe.git",
)

# TODO(yannic): Change to local_repository and let gclient handle syncs.
git_repository(
    name = "org_pocoo_jinja",
    commit = "ec8d55c17b08248ccbde7a270a1afa5eb6490d29",
    remote = "https://github.com/YBApp-Bot/org_pocoo_jinja.git",
)
