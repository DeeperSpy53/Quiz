#if defined _quiz_included
    #endinput
#endif
#define _quiz_included

/**
 *
 * Игрок ответил правильно
 *	-
 * @param iClient 			Индекс игрока
 *
 */
forward void Quiz_OnPlayerWin(int iClient);

/**
 *
 * Начало викторины
 *	-
 *
 */
forward void Quiz_OnQuizStart();


/**
 *
 * Конец викторины
 *	-
 *
 */
forward void Quiz_OnQuizEnd();

/**
 *
 * Игрок написал сообщение во время викторины
 *	-
 * @param iClient 			Индекс игрока
 *
 */
forward Action Quiz_OnClientAnswered(int iClient);

/**
 *
 * Запустить викторину
 *	-
 * @param iMode 			Режим викторины
 * 0 - Пример 1 - Случайное число 2 - Вопрос
 *
 */
native int Quiz_StartQuiz(int iMode);

/**
 *
 * Получить режим викторины
 *	-
 * 0 - Пример 1 - Случайное число 2 - Вопрос
 *
 */
native int Quiz_GetQuiz();

/**
 *
 * Получить ответ на пример или случайное число
 *
 */
native int Quiz_GetAnswer();

/**
 *
 * Получить ответ на вопрос
 *	-
 * @param sAnswer			Ответ на вопрос
 * @param iSize				Размер ответа на вопрос
 *
 */
native int Quiz_GetAnswerQuestion(char[] sAnswer, int iSize);
