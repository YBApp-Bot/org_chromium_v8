// Copyright 2014 the V8 project authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "src/compiler/load-elimination.h"

#include "src/compiler/graph.h"
#include "src/compiler/node-properties.h"
#include "src/compiler/simplified-operator.h"
#include "src/types.h"

namespace v8 {
namespace internal {
namespace compiler {

LoadElimination::~LoadElimination() {}

Reduction LoadElimination::Reduce(Node* node) {
  switch (node->opcode()) {
    case IrOpcode::kLoadField:
      return ReduceLoadField(node);
    default:
      break;
  }
  return NoChange();
}

namespace {

// If {node} is a CheckTaggedPointer, follow its input until {node} is no
// longer a CheckTaggedPointer.
Node* NormalizeCheckTaggedPointer(Node* node) {
  while (node->opcode() == IrOpcode::kCheckTaggedPointer) {
    node = NodeProperties::GetValueInput(node, 0);
  }
  return node;
}

}  // namespace

Reduction LoadElimination::ReduceLoadField(Node* node) {
  DCHECK_EQ(IrOpcode::kLoadField, node->opcode());
  FieldAccess const access = FieldAccessOf(node->op());
  Node* object = NodeProperties::GetValueInput(node, 0);
  for (Node* effect = NodeProperties::GetEffectInput(node);;
       effect = NodeProperties::GetEffectInput(effect)) {
    switch (effect->opcode()) {
      case IrOpcode::kLoadField: {
        FieldAccess const effect_access = FieldAccessOf(effect->op());
        if (object == NodeProperties::GetValueInput(effect, 0) &&
            access == effect_access && effect_access.type->Is(access.type)) {
          Node* const value = effect;
          ReplaceWithValue(node, value);
          return Replace(value);
        }
        break;
      }
      case IrOpcode::kStoreField: {
        if (access == FieldAccessOf(effect->op())) {
          Node* value_input = NormalizeCheckTaggedPointer(
              NodeProperties::GetValueInput(effect, 0));
          if (object == value_input) {
            Node* const value = NodeProperties::GetValueInput(effect, 1);
            Type* value_type = NodeProperties::GetType(value);
            Type* node_type = NodeProperties::GetType(node);
            // Make sure the replacement's type is a subtype of the node's
            // type. Otherwise we could confuse optimizations that were
            // based on the original type.
            if (value_type->Is(node_type)) {
              ReplaceWithValue(node, value);
              return Replace(value);
            } else {
              // This LoadField has stronger guarantees than the stored value
              // can give us, which suggests that we are probably in unreachable
              // code, guarded by some Check, so don't bother trying to optimize
              // this LoadField {node}.
              return NoChange();
            }
          }
          // TODO(turbofan): Alias analysis to the rescue?
          return NoChange();
        }
        break;
      }
      case IrOpcode::kBeginRegion:
      case IrOpcode::kStoreBuffer:
      case IrOpcode::kStoreElement: {
        // These can never interfere with field loads.
        break;
      }
      case IrOpcode::kFinishRegion:
      case IrOpcode::kCheckTaggedPointer: {
        // "Look through" FinishRegion nodes to make LoadElimination capable
        // of looking into atomic regions.
        if (object == effect) object = NodeProperties::GetValueInput(effect, 0);
        break;
      }
      case IrOpcode::kAllocate: {
        // Allocations don't interfere with field loads. In case we see the
        // actual allocation for the {object} we can abort.
        if (object == effect) return NoChange();
        break;
      }
      default: {
        if (!effect->op()->HasProperty(Operator::kNoWrite) ||
            effect->op()->EffectInputCount() != 1) {
          return NoChange();
        }
        break;
      }
    }
  }
  UNREACHABLE();
  return NoChange();
}

}  // namespace compiler
}  // namespace internal
}  // namespace v8
