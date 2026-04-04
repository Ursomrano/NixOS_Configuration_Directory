# Smudge: replaces HOSTNAME_PLACEHOLDER with your machine's hostname on checkout/pull
git config filter.hostname.smudge "sed 's/HOSTNAME_PLACEHOLDER/$(hostname)/g'"

# Clean: replaces your hostname with HOSTNAME_PLACEHOLDER when committing/pushing
git config filter.hostname.clean "sed 's/^  host = \".*\";/  host = \"HOSTNAME_PLACEHOLDER\";/g'"
