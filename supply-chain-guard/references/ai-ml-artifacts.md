# AI/ML Artifact Supply Chain

Use this reference when a task downloads, loads, updates, reviews, or approves models, datasets, tokenizers, embeddings, vector-store snapshots, LoRAs, adapters, fine-tunes, prompts, templates, or RAG sources.

AI/ML artifacts are dependencies. Some can execute code during loading; others can poison behavior through data, prompts, templates, labels, embeddings, or retrieval content.

## What to detect

Review changes that introduce or modify:

- Hugging Face, Kaggle, GitHub release, S3/GCS/Azure blob, OCI, IPFS, torrent, or direct HTTP model/dataset references.
- `transformers`, `diffusers`, `sentence-transformers`, `torch.hub`, `tensorflow`, `keras`, `jax`, `mlflow`, `ollama`, `llama.cpp`, `vllm`, `litellm`, LangChain, LlamaIndex, Haystack, or vector database download/load paths.
- `trust_remote_code=True`, custom tokenizers, custom pipeline code, prompt templates, chat templates, tool schemas, agent policies, or runtime plugin loading.
- `.pkl`, `.pickle`, `.pt`, `.pth`, `.bin`, `.h5`, `.npz`, `.npy`, `.safetensors`, `.gguf`, `.ggml`, `.onnx`, `.tflite`, `.parquet`, `.arrow`, `.jsonl`, model index files, tokenizer files, and adapter configs.
- RAG corpora, embedding caches, vector-store exports, evaluation datasets, fine-tuning data, synthetic traces, and benchmark fixtures.

## Default rules

- Prefer official publisher repositories and verified organization accounts over mirrors, reuploads, forks, or personal namespaces.
- Pin immutable revisions, release tags, commit SHAs, object versions, or OCI digests. Avoid branch names, `latest`, mutable bucket paths, and unversioned URLs.
- Prefer `safetensors`, GGUF, ONNX, TFLite, JSONL, Parquet, Arrow, CSV, and plain text formats when they fit the workflow.
- Treat Pickle, Python object arrays, PyTorch `.pt`/`.pth` checkpoints, custom TensorFlow/Keras objects, `torch.hub`, and arbitrary loader scripts as code execution.
- Do not use `trust_remote_code=True` unless the remote repository and exact revision have passed code review and human approval.
- Do not load unverified artifacts in an environment with package tokens, cloud credentials, SSH keys, production data, or publish permissions.
- Treat LoRAs, adapters, fine-tunes, embeddings, prompts, templates, and RAG data as high-risk behavior inputs even when they are not executable.
- Document the exact source URL, immutable revision, artifact filename, SHA-256, license, and approval rationale when the artifact becomes part of a reproducible workflow.

## Intake checklist

Before downloading or loading an artifact, answer:

1. **Need:** why the artifact is necessary and whether an existing checked-in or already approved artifact is enough.
2. **Identity:** publisher, repository or bucket, artifact names, immutable revision or digest, and expected file list.
3. **Age:** release/upload time meets the 7-day minimum or 14-day high-risk preference, unless a documented security-fix exception applies.
4. **Provenance:** model/dataset card, source repository, release notes, training-data or dataset origin, license, and maintainer history look consistent.
5. **Integrity:** published hash, signature, attestation, or locally computed SHA-256 from an isolated environment is recorded.
6. **Execution risk:** loader format, `trust_remote_code`, custom pipeline/tokenizer code, dynamic imports, network fetches, shell execution, and unsafe deserialization are reviewed.
7. **Poisoning risk:** prompts, chat templates, labels, evaluation data, embeddings, and retrieved content are reviewed for instructions, secrets, malicious links, or hidden payloads.
8. **Scope:** artifact is stored, cached, and exposed only where needed, with credentials and production data separated from first-load review.

## Safe loading preferences

- Use safe loader flags where available, such as `use_safetensors=True`, local-file-only modes after verification, and explicit revision pins.
- Disable remote-code loading by default.
- Load first in a sandbox, short-lived runner, or disposable container with no sensitive credentials.
- Compare the downloaded file list against the model/dataset card or release manifest. Unexpected scripts, binaries, notebooks, dynamic modules, or archives require review.
- For large artifacts, verify hashes before extraction or loading. Avoid extraction paths that can overwrite arbitrary files.
- For RAG sources, preserve source metadata and ingestion time so poisoned or disputed documents can be removed and embeddings rebuilt.

## Suspicious signals

- Repository ownership changes, sudden maintainer additions, renamed organizations, or popular-model forks with confusing names.
- A model card that does not match artifact contents, license, supported tasks, or source repository.
- Tokenizer, template, or config files that contain tool instructions, credential requests, endpoint changes, or unexpected URLs.
- Loader code that reads environment variables, home directories, shell history, cloud credentials, package tokens, SSH keys, browser profiles, or kubeconfigs.
- Runtime downloads from raw GitHub, object storage, paste sites, URL shorteners, newly registered domains, or unpinned mirrors.
- Obfuscated Python/JavaScript, base64 payloads, hidden Unicode, `eval`, `exec`, dynamic `import`, `subprocess`, `os.system`, or shell command construction.
- RAG corpora containing prompt injection, tool-use instructions, secrets, executable snippets, malicious URLs, or poisoned labels.

## Review searches

Useful local searches:

```sh
rg -n 'trust_remote_code|from_pretrained|snapshot_download|hf_hub_download|torch\\.hub|torch\\.load|pickle\\.load|joblib\\.load|load_model|mlflow|ollama|llama\\.cpp|gguf|safetensors' .
rg -n 'eval\\(|exec\\(|subprocess|os\\.system|process\\.env|os\\.environ|AWS_|AZURE_|GOOGLE_|GITHUB_TOKEN|NPM_TOKEN|KUBECONFIG|id_rsa|\\.ssh' .
rg -n 'prompt|template|system_message|tool_schema|retriever|vectorstore|embedding|fine[-_ ]?tune|lora|adapter|dataset|jsonl|parquet|arrow' .
rg -n '[\\u200B-\\u200F\\u202A-\\u202E\\u2060-\\u206F]' .
```

## Reporting standard

When approving or rejecting an AI/ML artifact change, include:

- exact artifact source, immutable revision or digest, and SHA-256
- whether the format can execute code during loading
- whether remote code, custom tokenizer/template behavior, or runtime fetches are present
- whether the artifact is old enough under the age policy
- unresolved license, provenance, privacy, or data-poisoning risks
