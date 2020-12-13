#include "delay.h"
#include "usart.h"
#include "imu_data_decode.h"
#include "packet.h"
 
/************************************************
 ALIENTEKս��STM32������ʵ��
 ����ʵ�� 
 ����֧�֣�www.openedv.com
 �Ա����̣�http://eboard.taobao.com 
 ��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡSTM32���ϡ�
 ������������ӿƼ����޹�˾  
 ���ߣ�����ԭ�� @ALIENTEK
************************************************/

/************************************************
 �������˵���
 ���Ե���ģ�飺 HI226 HI229
 ���ڽ�����������
 ������ֻ��ѧϰʹ�ã��۲��������������������;
 ����2��������HI226������HI229������
 ����1������2�ɹ����յ������ݴ�ӡ���ն���
 ������ն�һ��ָ����PC���ϴ��ڵ�������
 ������http://www.hipnuc.com
************************************************/

void dump_data_packet(receive_imusol_packet_t *data);     //��ӡ����
void SysTick_Handler(void);                               //SysTick�жϴ�����
void SysTick_Init(void);                                  //SysTick��ʼ������

static uint32_t frame_rate;                               //��ȡ֡Ƶ��
static uint8_t usart1_output_flag;                        //���ն������־

int main(void)
{		
    uint32_t i = 0;

    delay_init();	    	                               //��ʱ������ʼ��	  
    NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);        //����NVIC�жϷ���2:2λ��ռ���ȼ���2λ��Ӧ���ȼ�
    uart_init(115200);	                                   //���ڳ�ʼ��Ϊ115200
  
    imu_data_decode_init();                                //ӳ���������
    SysTick_Init();                                        //����SysTick����ʱ20ms

    while(1)
    {
        if(usart1_output_flag)
        {
            usart1_output_flag = 0;
            if(receive_gwsol.tag != KItemGWSOL)
			{
				/* printf imu data packet */
				dump_data_packet(&receive_imusol);
				putchar(10);
			}
			else
			{
				/* printf gw data packet */
				printf("        GW ID:  %-8d\n",receive_gwsol.gw_id);
				for(i = 0; i < receive_gwsol.n; i++)
				{ 
					dump_data_packet(&receive_gwsol.receive_imusol[i]);
					puts("");
				}
			}
		}
	}	 
}

/* 200ms interrupt */
void SysTick_Handler(void)
{
	static uint32_t div;    
	if(div == 5)
	{
		div = 0;
		frame_rate = frame_count;
		frame_count = 0;
		usart1_output_flag = 1;
	}
    
	div++;
}

/* serial usart2 interrupt functional */
void USART2_IRQHandler(void)                	            //����2�жϷ������
{
	uint8_t ch;
	if(USART_GetITStatus(USART2, USART_IT_RXNE) != RESET)   //�����ж� 
		ch = USART_ReceiveData(USART2);	                    //��ȡ���յ�������

	packet_decode(ch);                                      //��������
} 

/* SysTick initialization */
void SysTick_Init(void)
{
    SysTick->LOAD = (float)SystemCoreClock / 40;             
    SysTick->CTRL |= SysTick_CTRL_TICKINT_Msk;
    SysTick->CTRL |= SysTick_CTRL_ENABLE_Msk; 
}

/* printf hi229 or hi226 data packet*/
void dump_data_packet(receive_imusol_packet_t *data)
{
	if(bitmap & BIT_VALID_ID)
		printf("    Device ID:  %-8d\r\n",  data->id);
	printf("   Frame Rate: %4dHz\r\n", frame_rate);
	if(bitmap & BIT_VALID_ACC)
		printf("       Acc(G):	%8.3f %8.3f %8.3f\r\n",  data->acc[0],  data->acc[1],  data->acc[2]);
	if(bitmap & BIT_VALID_GYR)
		printf("   gyr(deg/s):	%8.2f %8.2f %8.2f\r\n",  data->gyr[0],  data->gyr[1],  data->gyr[2]);
	if(bitmap & BIT_VALID_MAG)
		printf("      mag(uT):	%8.2f %8.2f %8.2f\r\n",  data->mag[0],  data->mag[1],  data->mag[2]);
	if(bitmap & BIT_VALID_EUL)
		printf("   eul(R P Y):  %8.2f %8.2f %8.2f\r\n",  data->eul[0],  data->eul[1],  data->eul[2]);
	if(bitmap & BIT_VALID_QUAT)
		printf("quat(W X Y Z):  %8.3f %8.3f %8.3f %8.3f\r\n",  data->quat[0],  data->quat[1],  data->quat[2],  data->quat[3]);
}
