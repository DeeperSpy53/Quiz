public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErrMax)
{
	g_hForward_OnPlayerWin = CreateGlobalForward("Quiz_OnPlayerWin", ET_Ignore, Param_Cell);
	g_hForward_OnQuizStart = CreateGlobalForward("Quiz_OnQuizStart", ET_Ignore, Param_Cell);
	g_hForward_OnQuizEnd = CreateGlobalForward("Quiz_OnQuizEnd", ET_Ignore, Param_Cell);
	g_hForward_OnClientAnswered = CreateGlobalForward("Quiz_OnClientAnswered", ET_Hook, Param_Cell);
	g_hForward_OnPlayerLose = CreateGlobalForward("Quiz_OnPlayerLose", ET_Hook, Param_Cell);
	
	CreateNative("Quiz_StartQuiz", Native_StartQuiz);
	CreateNative("Quiz_GetQuiz", Native_GetQuiz);
	CreateNative("Quiz_GetAnswer", Native_GetAnswer);
	CreateNative("Quiz_GetAnswerQuestion", Native_GetAnswerQuestion);
	
	RegPluginLibrary("quiz");
	return APLRes_Success;
}

public int Native_StartQuiz(Handle hPlugin, int iNumParams)
{
	g_iValue = GetNativeCell(1);
	
	TimerCreate();
	return 1;
}

public int Native_GetQuiz(Handle hPlugin, int iNumParams)
{
	return g_iValue;
}

public int Native_GetAnswerQuestion(Handle hPlugin, int iNumParams)
{
	int iSize = GetNativeCell(2);
	SetNativeString(1, g_sAnswer, iSize);
	
	return 1;
}

public int Native_GetAnswer(Handle hPlugin, int iNumParams)
{
	return g_iAnswer;
}