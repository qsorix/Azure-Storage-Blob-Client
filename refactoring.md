# Moose to Moo Refactoring Plan

This document outlines the steps needed to refactor the Azure-Storage-Blob-Client repository from Moose to Moo.

## Overview

The repository currently uses Moose for object-oriented programming. Moo is a lighter-weight alternative that provides most of Moose's functionality with better performance, but lacks some advanced features. This refactoring will require careful handling of meta-programming features and custom attribute traits.

## Files Requiring Refactoring

### Core Classes (use Moose)
- `lib/Azure/Storage/Blob/Client.pm`
- `lib/Azure/Storage/Blob/Client/Caller.pm`
- `lib/Azure/Storage/Blob/Client/Exception.pm`
- `lib/Azure/Storage/Blob/Client/Service/Signer.pm`

### Call Classes (use Moose)
- `lib/Azure/Storage/Blob/Client/Call.pm` (uses Moose::Role)
- `lib/Azure/Storage/Blob/Client/Call/DeleteBlob.pm`
- `lib/Azure/Storage/Blob/Client/Call/DownloadBlob.pm`
- `lib/Azure/Storage/Blob/Client/Call/GetBlobProperties.pm`
- `lib/Azure/Storage/Blob/Client/Call/ListBlobs.pm`
- `lib/Azure/Storage/Blob/Client/Call/PutBlob.pm`

### Custom Attribute Traits (use Moose::Role)
- `lib/Azure/Storage/Blob/Client/Meta/Attribute/Custom/Trait/BodyParameter.pm`
- `lib/Azure/Storage/Blob/Client/Meta/Attribute/Custom/Trait/HeaderParameter.pm`
- `lib/Azure/Storage/Blob/Client/Meta/Attribute/Custom/Trait/URIParameter.pm`

## Moose Features Not Supported in Moo

### 1. Full Meta-Object Protocol (MOP)
**Issue**: Moo does not provide the full meta-object protocol that Moose offers. The codebase extensively uses:
- `$self->meta->get_attribute($name)`
- `$self->meta->get_attribute_list()`
- `$self->meta->make_immutable()`

**Impact**:
- `Call.pm` uses meta introspection in `serialize_uri_parameters()`, `serialize_header_parameters()`, and `serialize_body_parameters()` methods
- All classes use `__PACKAGE__->meta->make_immutable()`

**Solution**:
- **Replace meta introspection with explicit implementations**: Copy the three serialize methods from `Call.pm` to each Call subclass (`DeleteBlob.pm`, `ListBlobs.pm`, `PutBlob.pm`, `DownloadBlob.pm`, `GetBlobProperties.pm`)
- Each subclass will explicitly list which attributes should be serialized for URI, header, and body parameters
- This eliminates the need for meta introspection entirely
- Replace `make_immutable()` with Moo's built-in immutability (Moo classes are immutable by default after construction)

### 2. Custom Attribute Traits via Moose::Util::meta_attribute_alias
**Issue**: The codebase uses `Moose::Util::meta_attribute_alias()` to create custom attribute traits:
- `BodyParameter`
- `HeaderParameter`
- `URIParameter`

**Impact**: These traits are currently used to mark attributes, but with the new approach they become unnecessary.

**Solution**:
- **Remove trait classes entirely**: Since we're using explicit implementations in each Call subclass, the trait system is no longer needed
- Remove `traits => ['HeaderParameter']` and similar declarations from attribute definitions
- The trait classes can be deleted: `BodyParameter.pm`, `HeaderParameter.pm`, `URIParameter.pm`
- Remove `use` statements for trait classes from Call subclasses

### 3. Attribute Meta-Object Introspection
**Issue**: Code checks if attributes "do" a trait: `$self->meta->get_attribute($_)->does('HeaderParameter')`

**Impact**: Critical for `Call.pm` methods that serialize parameters based on attribute traits.

**Solution**:
- **Explicit parameter listing**: Each Call subclass will have its own implementation of the three serialize methods
- Instead of introspecting attributes, each method will explicitly list the relevant attributes
- Example for `DeleteBlob.pm`:
  - `serialize_header_parameters()`: explicitly return `api_version` and `delete_snapshots` with their header names
  - `serialize_uri_parameters()`: return empty hash (no URI parameters)
  - `serialize_body_parameters()`: return empty hash (no body parameters)

### 4. Type Constraints
**Issue**: Moo supports basic type constraints but may need `MooX::Types::MooseLike` for complex types.

**Impact**:
- `Maybe[Str]` type used in `DownloadBlob.pm`
- Other types: `Str`, `Bool`

**Solution**:
- Use `MooX::Types::MooseLike` for `Maybe[Str]` and other Moose-like types
- Or use `Types::Standard` from Type::Tiny (recommended, more modern)

### 5. Role Composition
**Issue**: `Call.pm` uses `Moose::Role` and classes use `with 'RoleName'`.

**Impact**: All Call subclasses compose the `Call` role.

**Solution**:
- Replace `Moose::Role` with `Moo::Role`
- `with` syntax works the same in Moo
- Ensure `requires` declarations work correctly

### 6. Class Inheritance
**Issue**: `Exception.pm` uses `extends 'Throwable::Error'`.

**Impact**: Single inheritance case.

**Solution**:
- Moo supports `extends` the same way
- Verify `Throwable::Error` is compatible with Moo (it should be)

### 7. BUILD Method
**Issue**: `DeleteBlob.pm` uses a `BUILD` method for validation.

**Impact**: One BUILD method in the codebase.

**Solution**:
- Moo supports `BUILD` methods identically to Moose
- No changes needed

## Refactoring Steps

### Phase 1: Preparation
1. **Update dependencies**
   - Add `Moo` to `cpanfile`
   - Add `MooX::Types::MooseLike` or `Types::Standard` for type constraints (for `Maybe[Str]` type)
   - Remove `Moose` from `cpanfile`

2. **Create test baseline**
   - Ensure all existing tests pass with Moose
   - Document current behavior for regression testing

### Phase 2: Refactor Call.pm Role
3. **Refactor `Call.pm` role**
   - Replace `use Moose::Role` with `use Moo::Role`
   - Remove `serialize_uri_parameters()`, `serialize_header_parameters()`, and `serialize_body_parameters()` methods from the role
   - Keep only the `requires` declarations (`endpoint`, `method`, `operation`)
   - These methods will be implemented explicitly in each Call subclass

### Phase 3: Refactor Call Subclasses
4. **For each Call subclass** (`DeleteBlob.pm`, `ListBlobs.pm`, `PutBlob.pm`, `DownloadBlob.pm`, `GetBlobProperties.pm`):
   - Replace `use Moose` with `use Moo`
   - Remove `use` statements for trait classes (no longer needed)
   - Remove `traits => [...]` from all attribute definitions
   - Remove `header_name => ...` from attribute definitions (will be hardcoded in serialize methods)
   - Remove `__PACKAGE__->meta->make_immutable()` (Moo is immutable by default)
   - **Add explicit serialize methods**:
     - `serialize_uri_parameters()`: Return hash of URI parameters explicitly listed
     - `serialize_header_parameters()`: Return hash with header names as keys, attribute values as values
     - `serialize_body_parameters()`: Return hash of body parameters explicitly listed
   - Update type constraints if needed

5. **Detailed parameter mapping for each Call subclass**:

   - **DeleteBlob.pm**:
     - Header parameters:
       - `api_version` → `'x-ms-version'` (required)
       - `delete_snapshots` → `'x-ms-delete-snapshots'` (optional)
     - URI parameters: None
     - Body parameters: None

   - **ListBlobs.pm**:
     - Header parameters:
       - `api_version` → `'x-ms-version'` (required)
     - URI parameters:
       - `prefix` → `'prefix'` (required, but check if defined)
       - `maxresults` → `'maxresults'` (optional)
       - `marker` → `'marker'` (optional)
     - Body parameters: None

   - **PutBlob.pm**:
     - Header parameters:
       - `api_version` → `'x-ms-version'` (required)
       - `blob_type` → `'x-ms-blob-type'` (required)
     - URI parameters: None
     - Body parameters:
       - `content` → `'content'` (required)

   - **DownloadBlob.pm**:
     - Header parameters:
       - `api_version` → `'x-ms-version'` (required)
       - `if_none_match` → `'If-None-Match'` (optional)
     - URI parameters: None
     - Body parameters: None

   - **GetBlobProperties.pm**:
     - Header parameters:
       - `api_version` → `'x-ms-version'` (required)
     - URI parameters: None
     - Body parameters: None

7. **Refactor main classes**
   - `Client.pm`: Replace `use Moose` with `use Moo`, remove `make_immutable()`
   - `Caller.pm`: Same as above
   - `Exception.pm`: Same as above, verify `extends` works
   - `Signer.pm`: Same as above

### Phase 4: Remove Trait Classes
6. **Delete trait classes** (no longer needed):
   - Delete `lib/Azure/Storage/Blob/Client/Meta/Attribute/Custom/Trait/BodyParameter.pm`
   - Delete `lib/Azure/Storage/Blob/Client/Meta/Attribute/Custom/Trait/HeaderParameter.pm`
   - Delete `lib/Azure/Storage/Blob/Client/Meta/Attribute/Custom/Trait/URIParameter.pm`
   - Remove the entire `Meta/Attribute/Custom/Trait/` directory structure if empty

### Phase 5: Type System Updates
7. **Update type constraints**
   - Replace `Maybe[Str]` with Moo-compatible type (from `MooX::Types::MooseLike` or `Types::Standard`)
   - Verify all `isa` constraints work correctly
   - Test type validation behavior

### Phase 6: Testing and Validation
8. **Run test suite**
   - Execute all tests
   - Verify serialize methods work correctly in each Call subclass
   - Ensure parameter serialization matches original behavior

9. **Performance testing**
    - Compare performance with Moose version
    - Verify memory usage improvements

10. **Documentation updates**
    - Update any documentation referencing Moose
    - Update README if needed
    - Note that trait classes have been removed

## Implementation Strategy: Explicit Serialize Methods

Instead of using meta introspection, each Call subclass will have explicit implementations of the three serialize methods. This approach is simpler, more maintainable, and doesn't require complex trait systems.

### Example: DeleteBlob.pm Implementation

```perl
sub serialize_uri_parameters {
  my $self = shift;
  return {};  # No URI parameters for DeleteBlob
}

sub serialize_header_parameters {
  my $self = shift;
  my %headers = (
    'x-ms-version' => $self->api_version,
  );
  $headers{'x-ms-delete-snapshots'} = $self->delete_snapshots if defined $self->delete_snapshots;
  return \%headers;
}

sub serialize_body_parameters {
  my $self = shift;
  return {};  # No body parameters for DeleteBlob
}
```

### Example: ListBlobs.pm Implementation

```perl
sub serialize_uri_parameters {
  my $self = shift;
  my %params = ();
  $params{prefix} = $self->prefix if defined $self->prefix;
  $params{maxresults} = $self->maxresults if defined $self->maxresults;
  $params{marker} = $self->marker if defined $self->marker;
  return \%params;
}

sub serialize_header_parameters {
  my $self = shift;
  return {
    'x-ms-version' => $self->api_version,
  };
}

sub serialize_body_parameters {
  my $self = shift;
  return {};  # No body parameters for ListBlobs
}
```

### Benefits of This Approach

1. **Simplicity**: No complex trait system or meta introspection needed
2. **Clarity**: It's immediately obvious which attributes are serialized where
3. **Performance**: Direct method calls are faster than meta introspection
4. **Maintainability**: Easy to modify serialization logic per class
5. **Moo Compatibility**: Works perfectly with Moo without additional dependencies

## Critical Considerations

1. **Backward Compatibility**: Ensure the public API remains unchanged - the serialize methods must return the same data structures
2. **Test Coverage**: Maintain 100% test coverage during refactoring - existing tests should pass after refactoring
3. **Parameter Handling**: Carefully handle optional parameters (only include in serialization if defined/truthy)
4. **Header Name Mapping**: Ensure header names match exactly (e.g., `'x-ms-version'`, `'x-ms-blob-type'`, `'If-None-Match'`)
5. **Performance**: Moo should provide better performance, but verify
6. **Dependencies**: Ensure all dependencies work with Moo (especially `Throwable::Error` for `Exception.pm`)

## Files to Modify Summary

- **14 files** using `use Moose` or `use Moose::Role`:
  - 4 core classes: `Client.pm`, `Caller.pm`, `Exception.pm`, `Signer.pm`
  - 1 role: `Call.pm`
  - 5 Call subclasses: `DeleteBlob.pm`, `DownloadBlob.pm`, `GetBlobProperties.pm`, `ListBlobs.pm`, `PutBlob.pm`
  - 3 trait classes: **To be deleted** (`BodyParameter.pm`, `HeaderParameter.pm`, `URIParameter.pm`)
- **cpanfile** for dependency updates
- **Test files** may need updates if they use Moose-specific features

## Estimated Complexity

- **Low-Medium Complexity**: Adding explicit serialize methods to each Call subclass (straightforward but requires careful attention to detail)
- **Low Complexity**: Basic class conversions (Moose → Moo)
- **Low Complexity**: Removing trait system (delete files, remove use statements)
- **Low Complexity**: Type constraint updates
- **Low Complexity**: Role refactoring (remove methods, keep requires)

## Notes

- Each Call subclass will have clear, explicit serialization logic that's easy to understand and maintain
- All `make_immutable()` calls can be removed as Moo classes are immutable by default
- The trait classes can be completely removed since they're no longer needed
- This approach is more maintainable long-term as it's explicit rather than relying on introspection

