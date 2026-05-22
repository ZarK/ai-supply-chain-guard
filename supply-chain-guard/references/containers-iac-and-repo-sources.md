# Containers, IaC, and Repository Sources

Use this reference when a task changes Dockerfiles, OCI images, OS package repositories, infrastructure-as-code, deployment manifests, vendored code, Git submodules, Git LFS objects, generated third-party code, or direct Git/tarball/binary sources.

These inputs are dependencies even when they do not appear in a package manifest. They can alter build output, cloud permissions, runtime images, deploy behavior, or source code reviewed by future agents.

## Containers and OCI artifacts

Detect:

- `Dockerfile`, `Containerfile`, `docker-compose.yml`, `compose.yaml`, Bake files, Dev Container config, Kubernetes image references, Helm chart image values, and CI image references.
- `FROM`, `COPY --from`, `ADD`, `RUN curl`, `RUN wget`, package repository additions, GPG key imports, binary downloads, and image tag changes.

Default rules:

- Pin base images and OCI artifacts by digest where practical, for example `image@sha256:<digest>`.
- Treat tag-only references such as `latest`, `stable`, `main`, `edge`, or `nightly` as mutable dependency versions.
- Prefer official, minimal, maintained base images and expected publisher namespaces.
- Verify signatures, attestations, SBOMs, or provenance where the publisher supports them, but still review Dockerfile behavior.
- Avoid `curl | sh`, `wget | sh`, unverified installers, broad OS upgrades, and downloaded binaries without checksums.
- Review added OS package repositories, imported signing keys, architecture selectors, mirrors, and package pins.
- Keep build secrets out of layers, logs, caches, and final images.

Before approving:

1. Identify every image name, registry, tag, digest, and publisher.
2. Verify the digest or immutable release and age.
3. Review all network downloads and extracted archives.
4. Review package-manager repository additions and signing keys.
5. Check whether build cache, artifact restore, or multi-stage copy crosses trust boundaries.
6. Summarize image, digest, signature/provenance status, and unresolved risk.

## Infrastructure-as-code and deployment config

Detect:

- Terraform/OpenTofu modules, Terragrunt, Pulumi packages, CDK constructs, CloudFormation templates, Helm charts, Kustomize overlays, Kubernetes manifests, Ansible roles/collections, Chef/Puppet modules, and deployment scripts.
- Remote modules, chart repositories, post-renderers, hooks, init containers, admission webhooks, external data sources, dynamic blocks, cloud IAM policies, and secrets references.

Default rules:

- Pin modules, charts, collections, and providers to exact versions, commits, or digests. Avoid branch refs and broad ranges.
- Verify publisher namespace, registry/source URL, release age, signatures/checksums where supported, and changelog diff.
- Review provider and module lockfiles such as `.terraform.lock.hcl`, `Chart.lock`, `requirements.lock`, and collection lock data where present.
- Treat chart hooks, Terraform external data sources, provisioners, local-exec/remote-exec, Ansible shell tasks, and post-renderers as code execution.
- Flag broad IAM roles, wildcard permissions, public network exposure, unauthenticated storage, privileged containers, hostPath mounts, host networking, and secret material in plain text.
- Do not let untrusted pull requests run IaC plans with production cloud credentials or write state, plans, caches, or artifacts consumed by privileged deploy jobs.

Before approving:

1. Identify all remote module/chart/provider sources and exact pins.
2. Verify source identity, immutable version, release age, and lockfile changes.
3. Review execution hooks and dynamic external fetches.
4. Review IAM, networking, secrets, state backends, and deployment permissions.
5. Summarize new infrastructure trust boundaries and required human approvals.

## Git, vendored code, submodules, and LFS

Detect:

- Git URL dependencies, submodules, `vendor/`, copied third-party source, generated SDKs, checked-in binary archives, Git LFS pointer changes, patches, and direct tarball URLs.
- `.gitmodules`, `.gitattributes`, lockfiles, package manifests, generated code directories, and release asset references.

Default rules:

- Pin Git sources to full commit SHAs, not branches or tags. Tags can be rewritten unless the project has strong protected-release guarantees.
- Verify repository ownership, expected namespace, license, commit date, signed tags/commits where available, and release notes.
- Treat vendored code and generated SDKs as dependency updates. Review the source version, generator version, generated diff, and embedded dependencies.
- For Git LFS, verify pointer object IDs and size changes. Treat large binary object swaps as dependency changes.
- Avoid vendoring minified or obfuscated code unless it is a reviewed upstream distribution artifact with a matching source release.
- Review submodule URL changes, path changes, branch tracking, and recursive submodules.

Before approving:

1. Identify source repository, immutable commit or object ID, and upstream release.
2. Verify the source still belongs to the expected publisher and has not shifted ownership suspiciously.
3. Compare vendored or generated code against the upstream artifact when practical.
4. Review licenses and notices for copied code.
5. Summarize source, commit/object ID, hash, and unresolved review gaps.

## Useful searches

```sh
rg -n 'FROM\\s+[^\\s]+:(latest|stable|edge|nightly|main|master)|FROM\\s+[^\\s@]+$|curl .*\\|.*(sh|bash)|wget .*\\|.*(sh|bash)|ADD\\s+https?://' Dockerfile Containerfile '**/Dockerfile' '**/Containerfile'
rg -n 'image:\\s*[^\\s@]+:(latest|stable|edge|nightly|main|master)|hostPath|privileged:\\s*true|hostNetwork:\\s*true|postRenderer|hooks:' .
rg -n 'source\\s*=\\s*"(git::|github.com|https?://)|version\\s*=\\s*"(main|master|latest|\\*)|local-exec|remote-exec|external"' .
rg -n 'git\\+|github:|https?://.*\\.(tgz|tar\\.gz|zip)|\\.gitmodules|submodule|lfs|vendor/' .
rg -n 'Action\\":\\s*"\\*"|Resource\\":\\s*"\\*"|Principal\\":\\s*"\\*"|0\\.0\\.0\\.0/0|::/0' .
```

## Reporting standard

For these surfaces, report:

- exact file and line where the dependency or execution behavior appears
- immutable image digest, module version, chart version, Git commit, LFS object ID, or tarball checksum
- whether signatures, attestations, checksums, or lockfiles were verified
- whether privileged credentials, cloud permissions, or deployment jobs are in scope
- whether the change should be split into a separate dependency/security review PR
