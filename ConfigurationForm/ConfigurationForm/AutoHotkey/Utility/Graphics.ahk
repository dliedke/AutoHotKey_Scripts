; Assists with everything related to the screen and drawing things to it

class WinStats
{
	__New(p_Title := "", p_Size := 0, p_Pos := 0, p_Center := 0)
	{
		this.m_Title := p_Title

		this.m_Size := p_Size
		if (this.m_Size = 0)
			this.m_Size := new Vector2()

		this.m_Pos := p_Pos
		if (this.m_Pos = 0)
			this.m_Pos := new Vector2()

		this.m_Center := p_Center
		if (this.m_Center = 0)
			this.m_Center := new Vector2()
	}

	Title[]
	{
		get {
			return this.m_Title
		}
		set {
			return this.m_Title := value
		}
	}

	Size[]
	{
		get {
			return this.m_Size
		}
		set {
			return this.m_Size := value
		}
	}
	Pos[]
	{
		get {
			return this.m_Pos
		}
		set {
			return this.m_Pos := value
		}
	}
	Center[]
	{
		get {
			return this.m_Center
		}
		set {
			return this.m_Center := value
		}
	}
}

class Graphics
{
	static __singleton :=
	static __init := False

	Init()
	{
		Graphics.__singleton := new Graphics()

		if WinExist(this.ApplicationTitle)
			WinActivate ; Activate Application Window if it exists

		this.SetActiveWinStats()
		if (this.ActiveWinStats.Size.Height > 1080)
			ToolTipFont("s10")

		Debug.AddToOnTooltip(new Delegate(Graphics, "OnTooltip"))
		Graphics.__init := False
	}

	__New()
	{
		global

		this.m_ApplicationTitle := IniReader.ReadProfileKey(ProfileSection.Preferences, "Application_Name")

		this.m_ActiveWinStats := new WinStats()
		this.m_CenterOffset
			:= new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Center_XOffset")
						, IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Center_YOffset"))

		Gui, +LastFound -Caption +E0x80000 +Owner +AlwaysOnTop +ToolWindow
		WinSet, ExStyle, +0x20
		this.m_GUI := WinExist()

		this.m_Token := Gdip_Startup()

		this.m_HBM := CreateDIBSection(300, 300)
		this.m_HDC := CreateCompatibleDC()
		this.m_OBM := SelectObject(this.m_HDC, this.m_HBM)
		this.m_Graphic := Gdip_GraphicsFromHDC(this.m_HDC)
		Gui, Show, NoActivate

		UpdateLayeredWindow(this.m_GUI, this.m_HDC, 0, 0, 300, 300)

		Gdip_SetCompositingMode(this.m_Graphic, 1)
		this.m_Brush := Gdip_BrushCreateSolid(0x0000000)
		Gdip_FillRectangle(this.m_Graphic, this.m_Brush, 0, 0, 300, 300)

		this.m_Reticule := Gdip_CreateBitmapFromFile("Images/Target.png")
		this.m_ReticuleSize
			:= new Vector2(Gdip_GetImageWidth(this.m_Reticule), Gdip_GetImageHeight(this.m_Reticule))

		Gdip_DrawImage(this.m_Graphic, this.m_Reticule, 0, 0, this.m_ReticuleSize.Width, this.m_ReticuleSize.Height)
		UpdateLayeredWindow(this.m_GUI, this.m_HDC)

		Gdip_DeleteBrush(this.m_Brush)
		Gdip_DisposeImage(this.m_Reticule)
	}

	ApplicationTitle[]
	{
		get {
			return this.__singleton.m_ApplicationTitle
		}
	}

	ActiveWinStats[]
	{
		get {
			return this.__singleton.m_ActiveWinStats
		}
		set {
			return this.__singleton.m_ActiveWinStats := value
		}
	}
	CenterOffset[]
	{
		get {
			return this.__singleton.m_CenterOffset
		}
	}

	ReticuleSize
	{
		get {
			return this.__singleton.m_ReticuleSize
		}
	}

	GetActiveWinStats()
	{
		local _title, _width, _height, _x, _y
		WinGetActiveStats, _title, _width, _height, _x, _y

		local _winStats := new WinStats(_title, new Vector2(_width, _height), new Vector2(_x, _y))

		return _winStats
	}

	SetActiveWinStats()
	{
		this.ActiveWinStats := this.GetActiveWinStats()

		this.ActiveWinStats.Center.X := (this.ActiveWinStats.Size.Width / 2)
		this.ActiveWinStats.Center.Y := (this.ActiveWinStats.Size.Height / 2)

		if (WinActive(this.ApplicationTitle))
		{
			this.ActiveWinStats.Center.X := this.ActiveWinStats.Center.X + this.CenterOffset.X
			this.ActiveWinStats.Center.Y := this.ActiveWinStats.Center.Y + this.CenterOffset.Y
		}
	}

	DrawReticule(p_ReticulePosition, p_CenterImage := True)
	{
		local _imageX := p_ReticulePosition.X
		local _imageY := p_ReticulePosition.Y

		if (p_CenterImage)
		{
			_imageX := _imageX - (this.ReticuleSize.Width / 2)
			_imageY := _imageY - (this.ReticuleSize.Height / 2)
		}

		Gui, 1:Show, x%_imageX% y%_imageY% NoActivate
	}
	HideReticule()
	{
		Gui, 1:Hide
	}

	DrawToolTip(p_Text, p_X, p_Y, p_Index, p_Alignment := "Left")
	{
		global

		ToolTip, % p_Text, % p_X, % p_Y, % p_Index

		if (p_Alignment = "Left")
			return

		local _x, _y, _w, _h
		WinGetPos, _x, _y, _w, _h, ahk_class tooltips_class32

		MsgBox, % _temp

		p_X := p_X - (_w / (p_Alignment = "Center" ? 2 : 1))
		p_Y := p_Y - (_h / 2)

		ToolTip, % p_Text, % p_X, % p_Y, % p_Index
	}
	HideToolTip(p_Index)
	{
		Tooltip, , , , % p_Index
	}

	OnTooltip()
	{
		local _debugText
			:= "'" . this.ActiveWinStats.Title . "' "
					. "Size: (" . Round(this.ActiveWinStats.Size.Width, 2) . ", " . Round(this.ActiveWinStats.Size.Height, 2) . ") "
					. "Pos: (" . this.ActiveWinStats.Pos.X . ", " . this.ActiveWinStats.Pos.Y . ") "
					. "Center: (" . Round(this.ActiveWinStats.Center.X, 2) . ", " . Round(this.ActiveWinStats.Center.Y, 2) . ")"

		return _debugText
	}
}