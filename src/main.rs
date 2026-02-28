use std::str::FromStr as _;

use ashpd::{
    AppID,
    desktop::global_shortcuts::{GlobalShortcuts, NewShortcut},
    register_host_app,
};
use tokio;

const APP_ID: &str = "org.nuisance.xwayland-global_shortcut-bridge";

async fn run() -> ashpd::Result<()> {
    let app_id = AppID::from_str(APP_ID)?;
    let _ = register_host_app(app_id).await?;

    let global_shortcuts = GlobalShortcuts::new().await?;

    let session = global_shortcuts.create_session(Default::default()).await?;

    let shortcuts = [NewShortcut::new("test_id", "test_description").preferred_trigger("F")];

    let request = global_shortcuts
        .bind_shortcuts(&session, &shortcuts, None, Default::default())
        .await?;

    let _ = request.response().inspect_err(|e| eprintln!("{e}"))?;

    let request = global_shortcuts
        .list_shortcuts(&session, Default::default())
        .await?;

    let _ = request.response().inspect_err(|e| eprintln!("{e}"))?;

    Ok(())
}

#[tokio::main]
async fn main() {
    run().await.expect("success");
}
