# Agents Sleep for Omarchy

Suspend the computer once every Claude agent and subagent has finished working. One icon in the
[Omarchy](https://omarchy.org) bar: click to arm, click to cancel, walk away.

![The Agents Sleep icon armed in the Omarchy bar, beside the indicators](preview.png)

- **Bar:** 󰒲 in full color while armed. When off the icon takes no space at all; hover the bar's
  center to reveal a dimmed 󰒳 in the same spot, like Stay Awake. The tooltip shows how many
  sessions are still active.
- **Placement:** put the widget right after Indicators, next to the clock. The icon then keeps its
  position whether armed or revealed, while the inactive indicators unfold away from it.
- **Done means quiet transcripts.** Every Claude session (Claude Code CLI, the desktop app, editor
  integrations and their subagents) writes its transcript under `~/.claude/projects` on each turn.
  The watcher treats the machine as done when no transcript has changed for the configured quiet
  minutes, checked twice in a row.
- **A warning first.** It then shows a critical notification, waits one more minute, checks again
  and runs `systemctl suspend`.
- **Never arms itself.** The watcher is a transient user unit, `agents-sleep`, started when you
  click. It survives a shell restart and is gone after the suspend or a reboot.

## Requirements

- Omarchy 4 (the Quickshell-based shell)
- `systemd` user session and `notify-send` (both ship with Omarchy)

## Install

```bash
omarchy plugin add https://github.com/lonhtm/omarchy-agents-sleep.git --enable
```

Update later with `omarchy plugin update lonh.agents-sleep`, then `omarchy restart shell`.

## Use

Click the icon. Or from a terminal, using the script in the plugin folder:

```bash
~/.config/omarchy/plugins/lonh.agents-sleep/agents-sleep on      # arm
~/.config/omarchy/plugins/lonh.agents-sleep/agents-sleep off     # cancel
~/.config/omarchy/plugins/lonh.agents-sleep/agents-sleep status  # armed or off, active sessions
~/.config/omarchy/plugins/lonh.agents-sleep/agents-sleep log     # follow the watcher
```

Symlink it into `~/.local/bin` if you want `agents-sleep` on your PATH.

## Settings

`quietMinutes` (default 5): how long every transcript must stay unchanged before the suspend.
Set it from the widget settings or:

```bash
omarchy bar set lonh.agents-sleep quietMinutes 10
```

## Privilege boundary

Nothing runs as root. The watcher only reads file modification times under `~/.claude/projects`
and calls `systemctl suspend`, which logind allows for the active local session.

## Uninstall

```bash
~/.config/omarchy/plugins/lonh.agents-sleep/agents-sleep off
omarchy plugin remove lonh.agents-sleep
```
