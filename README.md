File structure:
steghide
    ├── embed
    │   ├── cover_files
    │   ├── embedded_files
    │   └── secret_files
    |   └── embed_script.sh
    └── extract
        ├── embedded_files
        └── extracted_files
        └── extract_script.sh

EMBEDDING
  -> After loading cover files and secrect files, run embed_script.sh
  -> Embeded files will be stored inside embedded_files.

EXTRACTING
  -> Load the embedded files inside embedded_files folder.
  -> Run extract_script.sh
  -> Extracted files will be stored inside extracted_files folder.
