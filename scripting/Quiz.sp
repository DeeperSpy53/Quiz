#include <csgo_colors>

public Plugin myinfo =
{
	name = "Quiz",
	author = "DeeperSpy",
	version = "2.3.1"
};

int g_iMax, g_iMin, g_iValue, g_iDisplayAnswer, g_iAnswer,
	g_iExample, g_iRn, g_iQuestion,
	g_iModeQuestion, g_iMaxQuestion;
	
Handle g_hForward_OnPlayerWin, g_hForward_OnQuizStart, g_hForward_OnQuizEnd, g_hForward_OnClientAnswered, g_hForward_OnPlayerLose,
		g_hTimer, g_hQuizTimer;

bool g_bQuiz, g_bUs;
float g_fTimeEnd, g_fTime;
char g_sAnswer[1024];
KeyValues g_hKvQuestion;

#include "quiz/configs.sp"
#include "quiz/timers.sp"
#include "quiz/api.sp"

public void OnPluginStart()
{
	QuestionCfg();
	LoadTranslations("quiz.phrases");
}

public void OnMapStart()
{    
	g_bQuiz = false;
	MainCfg();
}

public void OnClientSayCommand_Post(int iClient, const char[] szCommand, const char[] szMessage) 
{		
	if(g_bQuiz)
	{
		int iResult;
		Call_StartForward(g_hForward_OnClientAnswered);
		Call_PushCell(iClient);
		Call_Finish(iResult);
		
		if (iResult != 0)
			return;
			
		if(g_iValue == 2)
		{
			if(StrContains(g_sAnswer, ";") != -1 && StrContains(g_sAnswer, szMessage) != -1)
			{
				char sAnswer[10][64];
				int iPieces = ExplodeString(g_sAnswer, ";", sAnswer, 10, 64);
				for (int i = 0; i < iPieces; i++)
				{
					if (StrEqual(szMessage, sAnswer[i]))
					{
						if(g_iDisplayAnswer == 1)
						{
							CGOPrintToChatAll("%t%t", "Prefix", "RewardClientQuestion", iClient, sAnswer[i]);
						}
						else
						{
							CGOPrintToChatAll("%t%t", "Prefix", "Reward", iClient);
						}
						g_iValue = 0;
					}
				}
			}
			else if(StrEqual(szMessage, g_sAnswer))
			{
				if(g_iDisplayAnswer == 1)
				{
					CGOPrintToChatAll("%t%t", "Prefix", "RewardClientQuestion", iClient, g_sAnswer);
				}
				else
				{
					CGOPrintToChatAll("%t%t", "Prefix", "Reward", iClient);
				}
				g_iValue = 0;
			}
			else
			{
				Call_StartForward(g_hForward_OnPlayerLose);
				Call_PushCell(iClient);
				Call_Finish();
				
				return;
			}
		}
		else
		{
			if(StringToInt(szMessage) == g_iAnswer)
			{
				CGOPrintToChatAll("%t%t", "Prefix", "RewardClient", iClient, g_iAnswer);
				g_iValue++;
			}
			else
			{
				Call_StartForward(g_hForward_OnPlayerLose);
				Call_PushCell(iClient);
				Call_Finish();
				
				return;
			}
		}
		
		if(g_hTimer)
		{
			KillTimer(g_hTimer);
			g_hTimer = null;     
		}
		
		g_bQuiz = false;
		
		Call_StartForward(g_hForward_OnPlayerWin);
		Call_PushCell(iClient);
		Call_Finish();
		
		Call_StartForward(g_hForward_OnQuizEnd);
		Call_PushCell(-1);
		Call_Finish();
	}
	
	return;
}