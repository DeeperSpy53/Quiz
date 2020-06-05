void QuestionCfg()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/quiz/quiz_question.ini");
	g_hKvQuestion = new KeyValues("Quiz");
	
	if(g_hKvQuestion.ImportFromFile(sPath))
	{
		g_iMaxQuestion = GetMaxQuestion();
		
		static char sQuestion[1024];
		g_hKvQuestion.Rewind();
		g_iDisplayAnswer = g_hKvQuestion.GetNum("DisplayAnswer", 0);
		g_iModeQuestion = g_hKvQuestion.GetNum("Mode", 1);
		
		g_hKvQuestion.GotoFirstSubKey();
		{
			do
			{
				if(g_hKvQuestion.GetSectionName(sQuestion, 1024))
				{
					g_hKvQuestion.GetString("Question", sQuestion, sizeof(sQuestion));
					if(sQuestion[0])
						g_hKvQuestion.SetString("Question", sQuestion);
					
					g_hKvQuestion.GetString("Answer", sQuestion, sizeof(sQuestion));
					if(sQuestion[0])
						g_hKvQuestion.SetString("Answer", sQuestion);
				}
			}	while g_hKvQuestion.GotoNextKey();
		}
	}
	else	SetFailState("[Quiz] file is not found (%s)", sPath);
}

void MainCfg()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/quiz/quiz.cfg");
	KeyValues hKv = new KeyValues("Quiz");
	if(hKv.ImportFromFile(sPath))
	{
		hKv.Rewind();
		g_iExample = hKv.GetNum("ModeExample");
		g_iRn = hKv.GetNum("ModeRn");
		g_iQuestion = hKv.GetNum("ModeQuestion");
		
		g_fTime = hKv.GetFloat("Time")
		g_hQuizTimer = CreateTimer(g_fTime, Timer_Quiz, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		g_fTimeEnd	= hKv.GetFloat("TimeEnd");
		
		g_iMin  = hKv.GetNum("Min");
		g_iMax = hKv.GetNum("Max");
	}
	else SetFailState("[Quiz] file is not found (%s)", sPath);
}

stock int GetMaxQuestion()
{
	int iCount;
	g_hKvQuestion.Rewind();
	if(g_hKvQuestion.GotoFirstSubKey())
	{
		do
		{
			iCount++;
		} 
		while (g_hKvQuestion.GotoNextKey());
	}
	return iCount;
}

void GetRandomQuestion()
{
	int iQuestion = GetRandomInt(1, g_iMaxQuestion), iCount;
	
	g_hKvQuestion.Rewind();
	if(g_hKvQuestion.GotoFirstSubKey())
	{
		do
		{
			if(iCount == iQuestion)
				break;

			iCount++;
		} 
		while (g_hKvQuestion.GotoNextKey());
	}
	return;
}

void KvUp()
{
	if(!g_bUs)
	{
		g_hKvQuestion.Rewind();
		g_hKvQuestion.GotoFirstSubKey();
		g_bUs = true;
		return;
	}
	if(g_hKvQuestion.GotoNextKey()) return;
	else
	{
		g_hKvQuestion.Rewind();
		g_hKvQuestion.GotoFirstSubKey();
		return;
	}
}