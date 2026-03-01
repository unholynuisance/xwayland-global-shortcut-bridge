use std::str::FromStr as _;

use libxdo::XDo;
use tokio;
use tokio_stream::StreamExt as _;

use ashpd::{
    AppID,
    desktop::global_shortcuts::{GlobalShortcuts, NewShortcut},
    register_host_app,
};

const APP_ID: &str = "org.nuisance.xwayland-global-shortcut-bridge";
const KEY: &str = "F12";

async fn run() -> anyhow::Result<()> {
    let app_id = AppID::from_str(APP_ID)?;
    let _ = register_host_app(app_id).await?;

    let global_shortcuts = GlobalShortcuts::new().await?;

    let session = global_shortcuts.create_session(Default::default()).await?;

    let shortcuts = [NewShortcut::new("test_id", "test_description").preferred_trigger(KEY)];

    let request = global_shortcuts
        .bind_shortcuts(&session, &shortcuts, None, Default::default())
        .await?;

    let result = request.response().inspect_err(|e| eprintln!("{e}"))?;

    dbg!(result);

    let request = global_shortcuts
        .list_shortcuts(&session, Default::default())
        .await?;

    let result = request.response().inspect_err(|e| eprintln!("{e}"))?;

    dbg!(result);

    let xdo = XDo::new(None)?;

    let mut stream_activated = global_shortcuts.receive_activated().await?;
    let mut stream_deactivated = global_shortcuts.receive_deactivated().await?;

    loop {
        tokio::select! {
            Some(activated) = stream_activated.next() => {
                dbg!(activated);
                let _ = xdo.send_keysequence_down(KEY, 0)?;
            },
            Some(deactivated) = stream_deactivated.next() => {
                dbg!(deactivated);
                let _ = xdo.send_keysequence_up(KEY, 0)?;
            },
            _ = tokio::signal::ctrl_c() => break,
            else => break,
        };
    }

    Ok(())
}

#[tokio::main]
async fn main() {
    run().await.expect("success");
}
