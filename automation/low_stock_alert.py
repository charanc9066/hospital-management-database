"""Low-stock alert script (demo)
Checks Inventory items and prints alerts for items below reorder_level.
"""

import pymysql
import os

DB_CONFIG = {
    'host': os.getenv('DB_HOST','localhost'),
    'user': os.getenv('DB_USER','root'),
    'password': os.getenv('DB_PASS',''),
    'database': os.getenv('DB_NAME','hospital_db'),
    'cursorclass': pymysql.cursors.DictCursor
}

def check_low_stock():
    conn = pymysql.connect(**DB_CONFIG)
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT item_id, item_name, quantity, reorder_level FROM Inventory WHERE quantity < reorder_level")
            return cur.fetchall()
    finally:
        conn.close()

if __name__ == '__main__':
    items = check_low_stock()
    if not items:
        print('No low-stock items.')
    for it in items:
        print(f"LOW STOCK: {it['item_name']} (id={it['item_id']}) qty={it['quantity']} reorder_level={it['reorder_level']}")
