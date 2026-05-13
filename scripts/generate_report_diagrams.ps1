$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$base = "C:\Users\Lenovo\Downloads\UniGuide-main"
$out = Join-Path $base "report_assets"
New-Item -ItemType Directory -Force -Path $out | Out-Null

function New-Canvas($w, $h, $bg) {
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.ColorTranslator]::FromHtml($bg))
    return @($bmp, $g)
}

function Font($name, $size, $style = "Regular") {
    return New-Object System.Drawing.Font($name, $size, [System.Drawing.FontStyle]::$style)
}

function Brush($hex) {
    return New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($hex))
}

function Pen($hex, $width = 2) {
    return New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml($hex), $width)
}

function Rect($g, $x, $y, $w, $h, $fill = "#ffffff", $border = "#d8e1ec") {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $r = 16
    $path.AddArc($x, $y, $r, $r, 180, 90)
    $path.AddArc($x + $w - $r, $y, $r, $r, 270, 90)
    $path.AddArc($x + $w - $r, $y + $h - $r, $r, $r, 0, 90)
    $path.AddArc($x, $y + $h - $r, $r, $r, 90, 90)
    $path.CloseFigure()
    $g.FillPath((Brush $fill), $path)
    $g.DrawPath((Pen $border 2), $path)
}

function CenterText($g, $text, $x, $y, $w, $h, $font, $color = "#172033") {
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    $g.DrawString($text, $font, (Brush $color), (New-Object System.Drawing.RectangleF($x, $y, $w, $h)), $sf)
}

function LeftText($g, $text, $x, $y, $font, $color = "#172033") {
    $g.DrawString($text, $font, (Brush $color), [float]$x, [float]$y)
}

function Arrow($g, $x1, $y1, $x2, $y2, $color = "#173f70") {
    $p = Pen $color 3
    $p.CustomEndCap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap(5, 7)
    $g.DrawLine($p, $x1, $y1, $x2, $y2)
}

$titleFont = Font "Segoe UI" 24 Bold
$headFont = Font "Segoe UI" 15 Bold
$font = Font "Segoe UI" 12 Regular
$small = Font "Segoe UI" 10 Regular

# 4. UML Use Case Diagram
$pair = New-Canvas 1280 760 "#f8fafc"; $bmp = $pair[0]; $g = $pair[1]
LeftText $g "UniGuide UML Use Case Diagram" 40 28 $titleFont
LeftText $g "Student-facing scope: resource browsing, upload/ingestion, AI doubt solving, and history." 40 70 $font "#5c6b7d"
LeftText $g "Student" 110 180 $headFont
$g.DrawEllipse((Pen "#173f70" 3), 130, 220, 55, 55)
$g.DrawLine((Pen "#173f70" 3), 158, 275, 158, 370)
$g.DrawLine((Pen "#173f70" 3), 95, 315, 220, 315)
$g.DrawLine((Pen "#173f70" 3), 158, 370, 115, 455)
$g.DrawLine((Pen "#173f70" 3), 158, 370, 205, 455)
Rect $g 320 125 850 560 "#ffffff" "#d8e1ec"
LeftText $g "UniGuide Application" 350 145 $headFont "#173f70"
$cases = @(
    @("Login / Continue as Guest", 405, 215),
    @("Browse Books", 720, 215),
    @("View PYQs", 405, 325),
    @("Ask Bot a Question", 720, 325),
    @("Upload / Ingest Syllabus", 405, 435),
    @("Generate Sample Paper", 720, 435),
    @("Open / Download PDF", 405, 545),
    @("View Chat History", 720, 545)
)
foreach ($c in $cases) {
    $g.DrawEllipse((Pen "#93c5fd" 2), $c[1], $c[2], 250, 58)
    CenterText $g $c[0] $c[1] $c[2] 250 58 $font
    Arrow $g 220 315 ($c[1]) ($c[2] + 29) "#64748b"
}
$bmp.Save((Join-Path $out "13_use_case_diagram.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

# 5. UI/UX Navigation Flow
$pair = New-Canvas 1280 720 "#eef3f8"; $bmp = $pair[0]; $g = $pair[1]
LeftText $g "UniGuide UI/UX Navigation Flow" 40 28 $titleFont
LeftText $g "Screen journey from app launch to chatbot, paper generation, and PYQ/resource sections." 40 70 $font "#5c6b7d"
$nodes = @(
    @("Splash Screen", 70, 145),
    @("Login / Guest", 310, 145),
    @("Dashboard", 550, 145),
    @("Chatbot", 250, 360),
    @("Paper Generator", 520, 360),
    @("PYQ Section", 790, 360),
    @("Books / Notes", 1010, 360),
    @("Answer + Sources", 210, 540),
    @("Generated Paper", 520, 540),
    @("PDF File List", 850, 540)
)
foreach ($n in $nodes) {
    Rect $g $n[1] $n[2] 190 80 "#ffffff" "#d8e1ec"
    CenterText $g $n[0] $n[1] $n[2] 190 80 $headFont
}
Arrow $g 260 185 310 185
Arrow $g 500 185 550 185
Arrow $g 645 225 345 360
Arrow $g 645 225 615 360
Arrow $g 645 225 885 360
Arrow $g 740 185 1105 360
Arrow $g 345 440 305 540
Arrow $g 615 440 615 540
Arrow $g 885 440 945 540
Arrow $g 1105 440 945 540
$bmp.Save((Join-Path $out "14_ui_navigation_flow.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

# 6. Sequence Diagram
$pair = New-Canvas 1280 760 "#ffffff"; $bmp = $pair[0]; $g = $pair[1]
LeftText $g "Sequence Diagram: Ask Bot a Question" 40 28 $titleFont
LeftText $g "Chronological flow from student query to RAG-backed response." 40 70 $font "#5c6b7d"
$actors = @(
    @("Student", 110),
    @("Flutter Frontend", 330),
    @("Flask API", 560),
    @("FAISS / SQLite", 800),
    @("LLM Service", 1040)
)
foreach ($a in $actors) {
    Rect $g ($a[1]-80) 125 160 55 "#eff6ff" "#bfdbfe"
    CenterText $g $a[0] ($a[1]-80) 125 160 55 $font
    $g.DrawLine((Pen "#94a3b8" 2), $a[1], 180, $a[1], 700)
}
$steps = @(
    @("1. Type question", 110, 330, 220),
    @("2. POST /chat", 330, 560, 285),
    @("3. Retrieve similar chunks", 560, 800, 350),
    @("4. Context returned", 800, 560, 415),
    @("5. Send prompt + context", 560, 1040, 480),
    @("6. Generated answer", 1040, 560, 545),
    @("7. JSON response", 560, 330, 610),
    @("8. Display answer", 330, 110, 675)
)
foreach ($s in $steps) {
    Arrow $g $s[1] $s[3] $s[2] $s[3]
    LeftText $g $s[0] ([Math]::Min($s[1], $s[2]) + 14) ($s[3] - 25) $small "#173f70"
}
$bmp.Save((Join-Path $out "15_sequence_diagram.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

Write-Output "Created use case, UI flow, and sequence diagrams."
