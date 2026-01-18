"""
数据库迁移脚本：为用户表添加新字段
运行方式: python migrate_add_user_fields.py
"""
import sqlite3
import os
import sys

# 添加项目根目录到路径
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.core.config import settings

def migrate_database():
    """添加用户表的新字段"""
    db_path = settings.SQLITE_DB_PATH
    
    # 如果数据库文件不存在，说明表还没创建，不需要迁移
    if not os.path.exists(db_path):
        print(f"数据库文件 {db_path} 不存在，表将在首次运行时自动创建。")
        return
    
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    try:
        # 检查并添加 avatar 字段
        try:
            cursor.execute("ALTER TABLE users ADD COLUMN avatar VARCHAR(500)")
            print("✓ 已添加 avatar 字段")
        except sqlite3.OperationalError as e:
            if "duplicate column name" in str(e).lower():
                print("✓ avatar 字段已存在")
            else:
                raise
        
        # 检查并添加 bio 字段
        try:
            cursor.execute("ALTER TABLE users ADD COLUMN bio VARCHAR(200)")
            print("✓ 已添加 bio 字段")
        except sqlite3.OperationalError as e:
            if "duplicate column name" in str(e).lower():
                print("✓ bio 字段已存在")
            else:
                raise
        
        # 检查并添加 tags 字段
        try:
            cursor.execute("ALTER TABLE users ADD COLUMN tags VARCHAR(500)")
            print("✓ 已添加 tags 字段")
        except sqlite3.OperationalError as e:
            if "duplicate column name" in str(e).lower():
                print("✓ tags 字段已存在")
            else:
                raise
        
        # 检查并添加 hide_total_loss 字段
        try:
            cursor.execute("ALTER TABLE users ADD COLUMN hide_total_loss INTEGER DEFAULT 0")
            print("✓ 已添加 hide_total_loss 字段")
        except sqlite3.OperationalError as e:
            if "duplicate column name" in str(e).lower():
                print("✓ hide_total_loss 字段已存在")
            else:
                raise
        
        # 检查并添加 hide_medals 字段
        try:
            cursor.execute("ALTER TABLE users ADD COLUMN hide_medals INTEGER DEFAULT 0")
            print("✓ 已添加 hide_medals 字段")
        except sqlite3.OperationalError as e:
            if "duplicate column name" in str(e).lower():
                print("✓ hide_medals 字段已存在")
            else:
                raise
        
        conn.commit()
        print("\n✅ 数据库迁移完成！")
        
    except Exception as e:
        conn.rollback()
        print(f"\n❌ 迁移失败: {e}")
        raise
    finally:
        conn.close()

if __name__ == "__main__":
    migrate_database()
