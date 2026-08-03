use anyhow::Result;
use axum::{
    routing::get,
    Json, Router,
};
use rusqlite::Connection;
use serde::{Deserialize, Serialize};
use std::net::SocketAddr;
use std::sync::{Arc, Mutex};

#[derive(Serialize, Deserialize, Clone)]
struct Product {
    id: u32,
    name: String,
    price: f64,
}

struct AppState {
    db: Mutex<Connection>,
}

fn init_db() -> Result<Connection> {
    let conn = Connection::open("maghribi.db")?;
    conn.execute(
        "CREATE TABLE IF NOT EXISTS products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            price REAL NOT NULL
        )",
        [],
    )?;
    // Seed if empty
    let count: i64 = conn.query_row("SELECT COUNT(*) FROM products", [], |r| r.get(0))?;
    if count == 0 {
        conn.execute(
            "INSERT INTO products (name, price) VALUES (?1, ?2)",
            ("T-shirt Maghribi", 19.99),
        )?;
        conn.execute(
            "INSERT INTO products (name, price) VALUES (?1, ?2)",
            ("Casquette Atlas", 12.50),
        )?;
    }
    Ok(conn)
}

#[tokio::main]
async fn main() -> Result<()> {
    let db = init_db()?;
    let state = Arc::new(AppState { db: Mutex::new(db) });

    let app = Router::new()
        .route("/", get(root))
        .route("/health", get(health))
        .route("/api/products", get(list_products).post(add_product))
        .with_state(state);

    let addr = SocketAddr::from(([0, 0, 0, 0], 3000));
    println!("🦀 Maghribi API (Rust/Axum + SQLite) démarré sur http://{}", addr);
    let listener = tokio::net::TcpListener::bind(addr).await?;
    axum::serve(listener, app).await?;
    Ok(())
}

async fn root() -> &'static str {
    "Maghribi Chill API — Rust + Axum + SQLite 🦀"
}

async fn health() -> &'static str {
    "ok"
}

async fn list_products(
    axum::extract::State(state): axum::extract::State<Arc<AppState>>,
) -> Json<Vec<Product>> {
    let db = state.db.lock().unwrap();
    let mut stmt = db.prepare("SELECT id, name, price FROM products").unwrap();
    let rows = stmt
        .query_map([], |r| {
            Ok(Product {
                id: r.get(0)?,
                name: r.get(1)?,
                price: r.get(2)?,
            })
        })
        .unwrap()
        .map(|r| r.unwrap())
        .collect();
    Json(rows)
}

async fn add_product(
    axum::extract::State(state): axum::extract::State<Arc<AppState>>,
    Json(p): Json<Product>,
) -> Json<Product> {
    let db = state.db.lock().unwrap();
    db.execute(
        "INSERT INTO products (name, price) VALUES (?1, ?2)",
        (&p.name, &p.price),
    )
    .unwrap();
    let id = db.last_insert_rowid() as u32;
    println!("Nouveau produit: {} ({} DH) -> id={}", p.name, p.price, id);
    Json(Product {
        id,
        name: p.name,
        price: p.price,
    })
}
