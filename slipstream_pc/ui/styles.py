APP_STYLE = """
QMainWindow {
    background: #f5f7fb;
}

QWidget {
    font-family: "Segoe UI";
    color: #1f2937;
}

QFrame#sidebar {
    background: #ffffff;
    border-right: 1px solid #e5e7eb;
}

QLabel#logo {
    font-size: 24px;
    font-weight: 700;
    color: #2563eb;
}

QLabel#logoSubtitle {
    font-size: 12px;
    color: #9ca3af;
}

QLabel#pageTitle {
    font-size: 26px;
    font-weight: 700;
    color: #111827;
}

QLabel#pageSubtitle {
    font-size: 13px;
    color: #6b7280;
}

QPushButton#navButton {
    background: transparent;
    border: none;
    border-radius: 8px;
    text-align: left;
    padding: 11px 14px;
    font-size: 14px;
    color: #6b7280;
}

QPushButton#navButton:hover {
    background: #f3f6fb;
    color: #2563eb;
}

QPushButton#navButton[selected="true"] {
    background: #eff6ff;
    color: #2563eb;
    font-weight: 600;
}

QFrame#statusCard {
    background: #ffffff;
    border: 1px solid #e5e7eb;
    border-radius: 12px;
}

QLabel#cardTitle {
    font-size: 12px;
    color: #6b7280;
}

QLabel#cardValue {
    font-size: 19px;
    font-weight: 700;
    color: #111827;
}

QLabel#cardDescription {
    font-size: 12px;
    color: #9ca3af;
}

QFrame#contentCard {
    background: #ffffff;
    border: 1px solid #e5e7eb;
    border-radius: 12px;
}

QLabel#sectionTitle {
    font-size: 17px;
    font-weight: 600;
    color: #111827;
}

QLabel#sectionSubtitle {
    font-size: 12px;
    color: #9ca3af;
}

QLabel#statusPill {
    background: #ecfdf5;
    color: #059669;
    border-radius: 12px;
    padding: 6px 12px;
    font-size: 12px;
    font-weight: 600;
}
"""