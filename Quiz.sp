#include <sourcemod>
#include <csgo_colors>
// csgo version
#pragma newdecls required

public Plugin myinfo =
{
	name = "Quiz",
	author = "DeeperSpy",
	version = "2.1.1"
};

int g_iMax, g_iMin,
	g_iExample, g_iRn,
	g_iAnswerRn, g_iAnswer;
bool g_bVar, g_bVarRn;
float g_fTimeEnd, g_fTimeEndRn;
char g_sPrefix[32];
Handle g_hTimer, g_hTimerRn, g_hForward_OnPlayerWin, 
	   g_hForward_OnQuizStart, g_hForward_OnQuizEnd;

public void OnPluginStart()
{	
	g_bVar = false;
	g_bVarRn = false;
	RegAdminCmd("sm_admquiz", Command_AdmQuiz, ADMFLAG_ROOT)
	
	LoadTranslations("quiz.phrases");
}

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	g_hForward_OnPlayerWin = CreateGlobalForward("Quiz_OnPlayerWin", ET_Ignore, Param_Cell, Param_Cell);
	g_hForward_OnQuizStart = CreateGlobalForward("Quiz_OnQuizStart", ET_Ignore, Param_Cell, Param_Cell);
	g_hForward_OnQuizEnd = CreateGlobalForward("Quiz_OnQuizEnd", ET_Ignore, Param_Cell, Param_Cell);
	
	RegPluginLibrary("quiz");
	return APLRes_Success;
}

public void OnMapStart()
{    
	g_bVar = false;
	g_bVarRn = false;
}

public void OnConfigsExecuted()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/quiz/quiz.cfg");
	KeyValues kv = new KeyValues("Quiz");
	if(!kv.ImportFromFile(sPath) || !kv.GotoFirstSubKey()) SetFailState("[Quiz] file is not found (%s)", sPath);
	
	kv.Rewind();
	kv.GetString("Prefix", g_sPrefix, sizeof(g_sPrefix));
	g_iExample = kv.GetNum("ModeExample", 1);
	g_iRn = kv.GetNum("ModeRn", 0);
	
	if(kv.JumpToKey("Example"))
	{
		if(g_iExample == 1)
			CreateTimer(kv.GetFloat("Time", 180.0), Timer_Message,_ , TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE) 
		g_fTimeEnd	= kv.GetFloat("TimeEnd", 60.0);
	}
	kv.Rewind();
	if(kv.JumpToKey("RandomNumber"))
	{
		if(g_iRn == 1)
			CreateTimer(kv.GetFloat("Time", 180.0), Timer_Number,_ , TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE) 
		g_fTimeEndRn  = kv.GetFloat("TimeEnd", 60.0);
		g_iMin  = kv.GetNum("Min", 1);
		g_iMax = kv.GetNum("Max", 100);
	}
	else
    {
        SetFailState("[Quiz] section Settings is not found (%s)", sPath);
    }
    
	delete kv;
}

public Action Command_AdmQuiz(int iClient, int iArgs)
{
	if(iClient)
		CreateAdmQuizMenu(iClient);
}

void CreateAdmQuizMenu(int iClient)
{
	char szBuffer[64];
	Menu hMenu = new Menu(Handler_AdminQuizMenu);
	hMenu.SetTitle("%t", "QuizMenuTitle");
	FormatEx(szBuffer, sizeof(szBuffer), "%t", "Answer");
	hMenu.AddItem("item1", szBuffer);
	FormatEx(szBuffer, sizeof(szBuffer), "%t", "CreateExampleMenu");
	if (g_iExample == 1)
		hMenu.AddItem("item2", szBuffer);
	else
		hMenu.AddItem("item2", szBuffer, ITEMDRAW_DISABLED);
	FormatEx(szBuffer, sizeof(szBuffer), "%t", "CreateRnMenu");
	if (g_iRn == 1)
		hMenu.AddItem("item3", szBuffer);
	else
		hMenu.AddItem("item3", szBuffer, ITEMDRAW_DISABLED);
	hMenu.Display(iClient, 30);
}

public int Handler_AdminQuizMenu(Menu hMenu, MenuAction action, int iClient, int iParam)
{
	switch(action)
	{
		case MenuAction_End:	CloseHandle(hMenu);
		case MenuAction_Select:
		{
            switch(iParam)
            {
                case 0:
                {
                	CGOPrintToChat(iClient, "%s%t", g_sPrefix, "AdminAnswer", g_iAnswer, g_iAnswerRn);
                	CreateAdmQuizMenu(iClient);
                }
                case 1:
                {
					CreateAdmQuizMenu(iClient);
					g_bVar = true;
					if(g_hTimer)  
					{
						KillTimer(g_hTimer);
						g_hTimer = null;     
					}
					CreateTimer(0.1, Timer_Message, _, TIMER_FLAG_NO_MAPCHANGE);
					CGOPrintToChat(iClient, "%s%t", g_sPrefix, "CreateExample");
                }
                case 2:
                {
					CreateAdmQuizMenu(iClient);
					g_bVarRn = true;
					if(g_hTimerRn)  
					{
						KillTimer(g_hTimerRn);
						g_hTimerRn = null;     
					}
					CreateTimer(0.1, Timer_Number, _, TIMER_FLAG_NO_MAPCHANGE);
                }
            }
		}
	}
}

public Action Timer_Number(Handle hTimer)
{
	int i, iCount;
	for(i = 1; i <= MaxClients; ++i)
    {
        if(IsClientInGame(i) && !IsFakeClient(i))
        {
			++iCount;
        }
    }
	if(iCount == 0)
    {
        return Plugin_Stop;
    }
	g_bVarRn = true;
	g_iAnswerRn = GetRandomInt(g_iMin, g_iMax);
	CGOPrintToChatAll("%s%t", g_sPrefix, "RnStart", g_iMin, g_iMax);
	g_hTimerRn = CreateTimer(g_fTimeEndRn, Timer_NumberEnd,_, TIMER_FLAG_NO_MAPCHANGE);
	Call_StartForward(g_hForward_OnQuizStart);
	Call_PushCell(-1);
	Call_Finish();
	return Plugin_Continue;
}

public Action Timer_NumberEnd(Handle hTimer)
{
	CGOPrintToChatAll("%s%t", g_sPrefix, "TimeIsOver", g_iAnswerRn);
	g_bVarRn = false;
	g_hTimerRn = null;
	Call_StartForward(g_hForward_OnQuizEnd);
	Call_PushCell(-1);
	Call_Finish();
}

public Action Timer_Message(Handle hTimer)
{	
	int i, iCount;
	for(i = 1; i <= MaxClients; ++i)
    {
        if(IsClientInGame(i) && !IsFakeClient(i))
        {
			++iCount;
        }
    }
	if(iCount == 0)
    {
        return Plugin_Stop;
    }
    
	int iExample 		= GetRandomInt(1, 10),
		iThreeDigit 	= GetRandomInt(1, 1000),
		iTwoDigit2 		= GetRandomInt(1, 100),
		iTwoDigit 		= GetRandomInt(1, 100),
		iUnambiguous 	= GetRandomInt(1, 10);
	g_bVar = true;
	switch(iExample)
	{
		case 1:		g_iAnswer=iThreeDigit+iTwoDigit2+iTwoDigit,		CGOPrintToChatAll("%s%t%d+%d+%d.", g_sPrefix, "Example", iThreeDigit, iTwoDigit2, iTwoDigit);
		case 2:		g_iAnswer=iThreeDigit-iTwoDigit2+iTwoDigit,		CGOPrintToChatAll("%s%t%d-%d+%d.", g_sPrefix, "Example", iThreeDigit, iTwoDigit2, iTwoDigit);
		case 3:		g_iAnswer=iThreeDigit-iTwoDigit2-iTwoDigit,		CGOPrintToChatAll("%s%t%d-%d-%d.", g_sPrefix, "Example", iThreeDigit, iTwoDigit2, iTwoDigit);
		case 4:		g_iAnswer=iThreeDigit+iTwoDigit2-iTwoDigit,		CGOPrintToChatAll("%s%t%d+%d-%d", g_sPrefix, "Example", iThreeDigit, iTwoDigit2, iTwoDigit);
		case 5:		g_iAnswer=iThreeDigit-iTwoDigit2*iTwoDigit,		CGOPrintToChatAll("%s%t%d-%d*%d.", g_sPrefix, "Example", iThreeDigit, iTwoDigit2, iTwoDigit);
		case 6:		g_iAnswer=iThreeDigit+iTwoDigit2*iTwoDigit,		CGOPrintToChatAll("%s%t%d+%d*%d.", g_sPrefix, "Example", iThreeDigit, iTwoDigit2, iTwoDigit);
		case 7:		g_iAnswer=iThreeDigit+iTwoDigit2*iTwoDigit+iUnambiguous,	CGOPrintToChatAll("%s%t%d+%d*%d+%d.", g_sPrefix, "Example", iThreeDigit, iTwoDigit2, iTwoDigit, iUnambiguous);
		case 8:		g_iAnswer=(iThreeDigit+iTwoDigit2)*iTwoDigit-iUnambiguous,	CGOPrintToChatAll("%s%t(%d+%d)*%d-%d.", g_sPrefix, "Example", iThreeDigit, iTwoDigit2, iTwoDigit, iUnambiguous);
		case 9:		g_iAnswer=(iThreeDigit-iTwoDigit2)-iTwoDigit-iUnambiguous,	CGOPrintToChatAll("%s%t(%d-%d)-%d-%d.", g_sPrefix, "Example", iThreeDigit, iTwoDigit2, iTwoDigit, iUnambiguous);
		case 10:	g_iAnswer=iThreeDigit-iTwoDigit2+(iTwoDigit*iUnambiguous),	CGOPrintToChatAll("%s%t%d-%d+(%d*%d).", g_sPrefix, "Example", iThreeDigit, iTwoDigit2, iTwoDigit, iUnambiguous);
	}
		
	g_hTimer = CreateTimer(g_fTimeEnd, Timer_MessageEnd,_, TIMER_FLAG_NO_MAPCHANGE);
	Call_StartForward(g_hForward_OnQuizStart);
	Call_PushCell(-1);
	Call_Finish();
	return Plugin_Continue;
}

public Action Timer_MessageEnd(Handle hTimer)
{
	CGOPrintToChatAll("%s%t", g_sPrefix, "TimeIsOver", g_iAnswer);
	g_bVar = false;
	g_hTimer = null;
	Call_StartForward(g_hForward_OnQuizEnd);
	Call_PushCell(-1);
	Call_Finish();
}

public void OnClientSayCommand_Post(int iClient, const char[] szCommand, const char[] szMessage) 
{		
	int iValue = StringToInt(szMessage);
	if(iValue == g_iAnswer && g_bVar)
	{	
		if(g_hTimer)
        {
			KillTimer(g_hTimer);
			g_hTimer = null; 	
        }
		g_bVar = false;		
		CGOPrintToChatAll("%s%t", g_sPrefix, "RewardClient", iClient, g_iAnswer);
		Call_StartForward(g_hForward_OnPlayerWin);
		Call_PushCell(iClient);
		Call_Finish();
	}
	else if(iValue == g_iAnswerRn && g_bVarRn)
	{
		if(g_hTimerRn)
        {
			KillTimer(g_hTimerRn);
			g_hTimerRn = null;     
        }
		g_bVarRn = false;
		CGOPrintToChatAll("%s%t", g_sPrefix, "RewardClient", iClient, g_iAnswerRn);
		Call_StartForward(g_hForward_OnPlayerWin);
		Call_PushCell(iClient);
		Call_Finish();
	}
	return;
}