#!/test/bash

# A wrapper script that:
# ... builds the image
# ... tags it
# ... optionally pushes it
# ... optionally restarts the container
# This keeps container-specific logic out of the global scripts.
