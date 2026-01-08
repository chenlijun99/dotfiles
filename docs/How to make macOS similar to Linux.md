# Making macOS Keyboard Shortcuts Work Like Linux/Windows

## Problem Statement

After years of Linux/Windows muscle memory, adapting to macOS keyboard shortcuts is challenging and doing so is also not worth it considering that I still actively use Linux. This guide documents a solution using [Kanata](https://github.com/jtroo/kanata) to remap macOS to behave like Linux/Windows while handling platform-specific quirks.

### Background: Key Naming Conventions

Modifier key terminology [varies across platforms and tools](https://askubuntu.com/questions/19558/what-are-the-meta-super-and-hyper-keys):

* **Command** (macOS) ≈ **Super** (Linux/Windows) ≈ **Meta** (Kanata/Emacs). Yet often terminal emulators interpret **Meta** as **Alt**.
* **Option** (macOS) ≈ **Alt** (Linux/Windows)
* **Control/Ctrl** exists on all platforms

### The Two Core Issues

1. **Physical Layout**: Apple ISO International English layout has:
   * `±` key left of `1` (where US layouts have `` ` ``)
   * `` ` `` / `~` key right of left Shift
   * **Modifier key positions**: Option and Command keys are swapped compared to typical Linux/Windows keyboard positions (where Alt is left of Super/Windows key)

2. **Shortcut Inconsistency**: macOS uses different modifier conventions:
   * Application switching: `Command+Tab` vs Linux's `Alt+Tab`
   * Most text/browser shortcuts: `Command+C/V/T/W` vs Linux's `Ctrl+C/V/T/W`
   * Tab switching in browsers: `Ctrl+Tab` (same as Linux, but inconsistent with other macOS shortcuts)
   * Terminal applications (e.g., Neovim): Still Ctrl-based, matching Linux

## Solution Overview

Use Kanata to remap modifier keys and shortcuts system-wide, with additional configuration in the terminal emulator to handle Ctrl-heavy applications like Neovim.

## Implementation

### Kanata Configuration

**Configuration files:**

* Main config: [`src/kanata/apple_iso_international_english.kdb`](../src/kanata/apple_iso_international_english.kdb)
* Shortcut layers: [`src/kanata/macos.kbd`](../src/kanata/macos.kbd)

**Strategy:**

1. **Fix Physical Layout** ([`apple_iso_international_english.kdb`](../src/kanata/apple_iso_international_english.kdb#L13-L20)):
   * Remap `±` to `` ` `` (grave/backtick)

2. **Swap Option and Command** ([`apple_iso_international_english.kdb`](../src/kanata/apple_iso_international_english.kdb#L22-L28)):
   * Physical `Option` → `Command` (with exceptions via `pc_lmet_layer`)
   * Physical `Command` → `Alt` (with exceptions via `pc_lalt_layer`)
   * This matches the expected Linux/Windows physical positions where Alt is left of Super/Windows key

3. **Remap Control to Command** ([`macos.kbd`](../src/kanata/macos.kbd), `pc_lctl_layer`):
   * Physical `Ctrl` → `Command` by default
   * Allows using Ctrl for common shortcuts (copy/paste/etc.) which macOS expects as Command
   * **Example exception**: `Ctrl+Tab` stays as `Ctrl+Tab` (not `Command+Tab`) for within-app tab switching
   * Other exceptions handle word-wise navigation (`Ctrl+Left/Right` → `Option+Left/Right`) and deletion

4. **Configure Layer Exceptions**:
   * `pc_lalt_layer`: Handles cases like `Command+Tab` for application switching (see [`macos.kbd`](../src/kanata/macos.kbd#L38-L60))
   * `pc_lmet_layer`: Handles system shortcuts like lock screen and [Dock item focusing](../src/kanata/macos.kbd#L73-L89) (see [`macos.kbd`](../src/kanata/macos.kbd#L62-L89))

5. **Right Side Modifiers** ([`apple_iso_international_english.kdb`](../src/kanata/apple_iso_international_english.kdb#L30-L33)):
   * Right `Option` → Right `Ctrl`
   * Right `Command` → Custom layer for media/mouse controls

### Terminal Emulator: Ghostty

**Configuration:** [`src/config/ghostty/config`](../src/config/ghostty/config)

**Why [Ghostty](https://ghostty.org/docs):**

* ✅ Text-based configuration (version controllable)
* ✅ Supports [modifier remapping](https://ghostty.org/docs/config/reference#key-remap): `key-remap = super=ctrl`
* ✅ Proper [Option-as-Alt support](https://ghostty.org/docs/config/reference#macos-option-as-alt): `macos-option-as-alt = true`
* ✅ All keybindings can be customized/cleared

**Key Configuration:**

```
key-remap = super=ctrl
macos-option-as-alt = true
keybind=clear  # Remove all default keybinds to avoid conflicts
```

**How It Works Together:**

```
User presses Ctrl+W in Ghostty:
  → Kanata remaps to Command+W
  → Ghostty remaps Command back to Ctrl
  → Neovim receives Ctrl+W ✓
```

**Caveat:** Some macOS system shortcuts (e.g., `Command+H` for hide window) cannot be overridden by applications. Solution: Remap in System Settings → Keyboard → Keyboard Shortcuts → App Shortcuts, or avoid those specific combinations.

**Alternative Terminal Emulators (Not Recommended):**

* **macOS Terminal.app**: Only supports Option-as-Meta, no modifier remapping
* **[Alacritty](https://github.com/alacritty/alacritty/issues/62)**: Only maps Option-as-Alt, no Command/Control remapping
* **iTerm2**: Supports modifier remapping but lacks good text-based configuration

## Setup Instructions

Most of the setup is automated via nix-darwin and kanata autostarts as daemon using `launchd`. However, permissions needs to be manually granted to the kanata binary. See [How to use Kanata from Homebrew and LaunchCtl for macOS #1537](https://github.com/jtroo/kanata/discussions/1537).

1. **Input Monitoring**: System Settings → Privacy & Security → Input Monitoring → Enable Kanata
2. **Accessibility**: System Settings → Privacy & Security → Accessibility → Enable Kanata
