public Action Timer_Quiz(Handle hTimer)
{		
	Call_StartForward(g_hForward_OnQuizStart);
	Call_PushCell(-1);
	Call_Finish();

	if(g_iValue == 0)
	{
		if(g_iExample == 1)
		{
			char sExample[16];
			
			int iExample 		= GetRandomInt(1, 5),
				iThreeDigit 	= GetRandomInt(1, 1000),
				iTwoDigit2 		= GetRandomInt(1, 100),
				iTwoDigit 		= GetRandomInt(1, 100),
				iUnambiguous 	= GetRandomInt(1, 10);
				
			switch(iExample)
 			{
				case 1:		Format(sExample, sizeof(sExample), "%d+%d+%d", iThreeDigit, iTwoDigit2, iTwoDigit), g_iAnswer = iThreeDigit + iTwoDigit2 + iTwoDigit;
				case 2:		Format(sExample, sizeof(sExample), "%d+%d", iTwoDigit, iTwoDigit2), 		g_iAnswer = iTwoDigit + iTwoDigit2;
				case 3:		Format(sExample, sizeof(sExample), "%d-%d.", iThreeDigit, iUnambiguous), 	g_iAnswer=iThreeDigit-iUnambiguous;
				case 4:		Format(sExample, sizeof(sExample), "%d+%d-%d", iThreeDigit, iTwoDigit2, iTwoDigit), g_iAnswer=iThreeDigit+iTwoDigit2-iTwoDigit;
				case 5:		Format(sExample, sizeof(sExample), "(%d-%d)-%d-%d.", iThreeDigit, iTwoDigit2, iTwoDigit, iUnambiguous), g_iAnswer=(iThreeDigit-iTwoDigit2)-iTwoDigit-iUnambiguous;
			}
			
			CGOPrintToChatAll("%t%t", "Prefix", "Example", sExample);
		}
		else	g_iValue++;
	}
	
	if(g_iValue == 1)
	{
		if(g_iRn == 1)
		{
			g_iAnswer = GetRandomInt(g_iMin, g_iMax);
			CGOPrintToChatAll("%t%t", "Prefix", "RnStart", g_iMin, g_iMax);
		}
		else	g_iValue++;
	}
	
	if(g_iValue == 2)
	{
		if(g_iQuestion == 1)
		{
			KvUp();
			static char sQuestion[1024];	sQuestion[0]='\0';
			g_hKvQuestion.GetString("Question", sQuestion, sizeof(sQuestion));
			if(sQuestion[0])
				CGOPrintToChatAll("%t%s", "Prefix", sQuestion);

			sQuestion[0]='\0';
			g_hKvQuestion.GetString("Answer", sQuestion, sizeof(sQuestion));
			if(sQuestion[0])
				g_sAnswer = sQuestion;
		}
		else	g_iValue = 0;
	}
	
	g_bQuiz = true;
	g_hTimer = CreateTimer(g_fTimeEnd, Timer_QuizEnd,_, TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Continue;
}

public Action Timer_QuizEnd(Handle hTimer)
{
	if(g_iValue == 2)
	{
		if(g_iDisplayAnswer == 1)
		{
			if(StrContains(g_sAnswer, ";", false) != -1)
			{
				char sAnswer[10][64];
				int iPieces = ExplodeString(g_sAnswer, ";", sAnswer, 10, 64);
				for (int i = 0; i < iPieces; i++)
				{
					CGOPrintToChatAll("%t%t", "Prefix", "TimeIsOverQuestion", sAnswer[i]);
					break;
				}	
			}
			else	CGOPrintToChatAll("%t%t", "Prefix", "TimeIsOverQuestion", g_sAnswer);
		}
		else
		{
			CGOPrintToChatAll("%t%t", "Prefix", "TimeIsOverNotAnswer");
		}
		
		g_iValue = 0;
	}
	else
	{
		g_iValue++;
		CGOPrintToChatAll("%t%t", "Prefix", "TimeIsOver", g_iAnswer);
	}
	
	g_bQuiz = false;
	
	Call_StartForward(g_hForward_OnQuizEnd);
	Call_PushCell(-1);
	Call_Finish();
}

void TimerCreate()
{
	if(g_hTimer != INVALID_HANDLE)
	{
		KillTimer(g_hTimer);
		g_hTimer = INVALID_HANDLE;     
	}
	
	if(g_hQuizTimer != INVALID_HANDLE)
	{
		KillTimer(g_hQuizTimer);
		g_hQuizTimer = null;     
	}
	
	CreateTimer(0.1, Timer_Quiz, _, TIMER_FLAG_NO_MAPCHANGE);
	g_hQuizTimer = CreateTimer(g_fTime, Timer_Quiz,_ , TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE) 
}
