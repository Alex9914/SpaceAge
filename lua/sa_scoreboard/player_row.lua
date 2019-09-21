
include( "player_infocard.lua" )

surface.CreateFont("SA_ScoreboardPlayerName", { font = "coolvetica", size = 20, weight = 500, antialias = true, shadow = false})

local texGradient = surface.GetTextureID( "gui/center_gradient" )

local texRatings = {}
texRatings[ 'none' ] 		= surface.GetTextureID( "gui/silkicons/user" )
texRatings[ 'smile' ] 		= surface.GetTextureID( "gui/silkicons/emoticon_smile" )
texRatings[ 'bad' ] 		= surface.GetTextureID( "gui/silkicons/exclamation" )
texRatings[ 'love' ] 		= surface.GetTextureID( "gui/silkicons/heart" )
texRatings[ 'artistic' ] 	= surface.GetTextureID( "gui/silkicons/palette" )
texRatings[ 'star' ] 		= surface.GetTextureID( "gui/silkicons/star" )
texRatings[ 'builder' ] 	= surface.GetTextureID( "gui/silkicons/wrench" )

surface.GetTextureID( "gui/silkicons/emoticon_smile" )
local PANEL = {}

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Paint()
      local _team = self.Player:Team()
	local color = team.GetColor(_team)
	
	if ( self.Player:Team() == TEAM_CONNECTING ) then
		color = Color( 200, 120, 50, 255 )
		end
		
		if ( self.Open || self.Size != self.TargetSize ) then
	
		draw.RoundedBox( 4, 0, 16, self:GetWide(), self:GetTall() - 16, color )
		draw.RoundedBox( 4, 2, 16, self:GetWide()-4, self:GetTall() - 16 - 2, Color( color.r, color.g, color.b, 255 ) )
		
		surface.SetTexture( texGradient )
		surface.SetDrawColor( 0, 0, 0, 200 )
		surface.DrawTexturedRect( 2, 16, self:GetWide()-4, self:GetTall() - 16 - 2 ) 
	
	end
	
	draw.RoundedBox( 4, 0, 0, self:GetWide(), 24, color )
	
	surface.SetTexture( texGradient )
	surface.SetDrawColor( 0, 0, 0, 130 )
	surface.DrawTexturedRect( 0, 0, self:GetWide(), 24 ) 
	
	surface.SetTexture( self.texRating )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 4, 4, 16, 16 ) 	
	
	return true

end

/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:SetPlayer( ply )

	self.Player = ply
	
	self.infoCard:SetPlayer( ply )
	
	self:UpdatePlayerData()

end

function PANEL:CheckRating( name, count )

	if ( self.Player:GetNetworkedInt( "Rating."..name, 0 ) > count ) then
		count = self.Player:GetNetworkedInt( "Rating."..name, 0 )
		self.texRating = texRatings[ name ]
	end
	
	return count

end

/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:UpdatePlayerData()

	if ( !self.Player ) then return end
	if ( !self.Player:IsValid() ) then return end

	local LeaderCap = ""
	if self.Player:GetNWBool("isfurry") == true then
		LeaderCap = LeaderCap.." [Furry]"
	end
	if self.Player:GetNWBool("isleader") == true then
		LeaderCap = LeaderCap.." [Leader]"
	end	
	self.lblName:SetText( team.GetName(self.Player:Team()).. LeaderCap .." - "..self.Player:Nick() )
	self.lblScore:SetText( AddCommasToInt(self.Player:GetNWInt("Score")) )
	--self.lblTC:SetText( self.Player:GetNWInt("TerraCredits") )
	self.lblPing:SetText( self.Player:Ping() )
	
	// Work out what icon to draw
	self.texRating = surface.GetTextureID( "gui/silkicons/emoticon_smile" )
	
	self.texRating = texRatings[ 'none' ]
	local count = 0
	
	count = self:CheckRating( 'smile', count )
	count = self:CheckRating( 'love', count )
	count = self:CheckRating( 'artistic', count )
	count = self:CheckRating( 'star', count )
	count = self:CheckRating( 'builder', count )
	
	count = self:CheckRating( 'bad', count )

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Init()

	self.Size = 32
	self:OpenInfo( false )
	
	self.infoCard	= vgui.Create( "SA_ScorePlayerInfoCard", self )
	
	self.lblName 	= vgui.Create( "DLabel", self )
	self.lblScore 	= vgui.Create( "DLabel", self )
	--self.lblTC	 	= vgui.Create( "DLabel", self )
	self.lblPing 	= vgui.Create( "DLabel", self )
	
	// If you don't do this it'll block your clicks
	self.lblName:SetMouseInputEnabled( false )
	self.lblScore:SetMouseInputEnabled( false )
	--self.lblTC:SetMouseInputEnabled( false )
	self.lblPing:SetMouseInputEnabled( false )

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()

	self.lblName:SetFont( "SA_ScoreboardPlayerName" )
	self.lblScore:SetFont( "SA_ScoreboardPlayerName" )
	--self.lblTC:SetFont( "SA_ScoreboardPlayerName" )
	self.lblPing:SetFont( "SA_ScoreboardPlayerName" )
	
	self.lblName:SetFGColor( color_black )
	self.lblScore:SetFGColor( color_black )
	--self.lblTC:SetFGColor( color_black )
	self.lblPing:SetFGColor( color_black )

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:DoClick()

	if ( self.Open ) then
		surface.PlaySound( "ui/buttonclickrelease.wav" )
	else
		surface.PlaySound( "ui/buttonclick.wav" )
	end

	self:OpenInfo( !self.Open )

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:OpenInfo( bool )

	if ( bool ) then
		self.TargetSize = 150
	else
		self.TargetSize = 24
	end
	
	self.Open = bool

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Think()

	if ( self.Size != self.TargetSize ) then
	
		self.Size = math.Approach( self.Size, self.TargetSize, (math.abs( self.Size - self.TargetSize ) + 1) * 10 * FrameTime() )
		self:PerformLayout()
		SCOREBOARD:InvalidateLayout()
	//	self:GetParent():InvalidateLayout()
	
	end
	
	if ( !self.PlayerUpdate || self.PlayerUpdate < CurTime() ) then
	
		self.PlayerUpdate = CurTime() + 0.5
		self:UpdatePlayerData()
		
	end

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self:SetSize( self:GetWide(), self.Size )
	
	self.lblName:SizeToContents()
	self.lblName:SetPos( 24, 2 )
	
	local COLUMN_SIZE = 50
	
	self.lblPing:SetPos( self:GetWide() - COLUMN_SIZE * 1, 0 )
	--self.lblTC:SetPos( self:GetWide() - COLUMN_SIZE * 2, 0 )
	self.lblScore:SizeToContents()
	self.lblScore:SetPos( self:GetWide() - COLUMN_SIZE * 4, 2 )
	if ( self.Open || self.Size != self.TargetSize ) then
	
		self.infoCard:SetVisible( true )
		self.infoCard:SetPos( 4, self.lblName:GetTall() + 10 )
		self.infoCard:SetSize( self:GetWide() - 8, self:GetTall() - self.lblName:GetTall() - 10 )
	
	else
	
		self.infoCard:SetVisible( false )
	
	end
	
	

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:HigherOrLower( row )

	if ( self.Player:Team() == TEAM_CONNECTING ) then return false end
	if ( row.Player:Team() == TEAM_CONNECTING ) then return true end
	
	if ( self.Player:Team() == row.Player:Team() ) then
		local tmp1 = self.Player:GetNWInt("Score")
		local tmp2 = row.Player:GetNWInt("Score")
		return tonumber(tmp1) > tonumber(tmp2)
	end
	return self.Player:Team() > row.Player:Team()
end
vgui.Register( "SA_ScorePlayerRow", PANEL, "Button" )