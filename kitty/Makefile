.PHONY: sync-pull sync-push sync-pull-dry sync-push-dry sync-status lint verify-repo verify-live backup

KITTY_LIVE_DIR ?= $(HOME)/.config/kitty
SYNC_SCRIPT := $(CURDIR)/scripts/sync.sh
VERIFY_SCRIPT := $(CURDIR)/verify-config.sh

sync-pull:
	KITTY_LIVE_DIR=$(KITTY_LIVE_DIR) $(SYNC_SCRIPT) pull

sync-pull-dry:
	DRY_RUN=1 KITTY_LIVE_DIR=$(KITTY_LIVE_DIR) $(SYNC_SCRIPT) pull

sync-push:
	KITTY_LIVE_DIR=$(KITTY_LIVE_DIR) $(SYNC_SCRIPT) push

sync-push-dry:
	DRY_RUN=1 KITTY_LIVE_DIR=$(KITTY_LIVE_DIR) $(SYNC_SCRIPT) push

sync-status:
	KITTY_LIVE_DIR=$(KITTY_LIVE_DIR) $(SYNC_SCRIPT) status

lint:
	$(CURDIR)/scripts/lint.sh

verify-repo:
	KITTY_ROOT=$(CURDIR) $(VERIFY_SCRIPT)

verify-live:
	KITTY_ROOT=$(KITTY_LIVE_DIR) $(VERIFY_SCRIPT)

backup:
	cp $(KITTY_LIVE_DIR)/kitty.conf $(KITTY_LIVE_DIR)/kitty.conf.backup-$$(date +%Y%m%d-%H%M%S)
