//+------------------------------------------------------------------+
//|                                                     ToEasyV6.mq4 |
//|                             Copyright 2017, Bocun Software Corp. |
//|                                            https://www.58boc.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Bocun Software Corp."
#property link      "https://www.58boc.com"
#property version   "1.00"
#property strict

//--- input parameters

input bool   buy_enable = true; //做多开启
input bool   sel_enable = true; //做空开启

//马丁逆势加仓
extern bool   martin_enable = true; //马丁开启
extern double basic_lots = 0.01;  //基础手数
extern int    basic_balance = 10000; //基础余额
input int    lots_mode =0;     //仓位模型(0:使用基础手数,1:根据余额复利)
input int    add_mode =0;      //加仓模型(0:等比加仓,1:等差加仓)
input double lots_multiple =2;  //等比加仓倍数
input double lots_increment = 1.0; //基于基础手数等差加仓比例
input int    max_trade =10; //最大开单量
input int    basic_pip =69;      //基础间距
input int    pip_mode = 0;         //间距模型(0:使用固定间距,1:根据高低点计算,2:根据开仓次数等比增加,3:根据开仓次数等差增加)
input double pip_multiple = 2; //等比加距倍数
input double pip_increment = 0.3;  //基于基础间距等差加距比例
input int    profit_mode =1;    //止盈模式(0:固定设置,1:根据盈亏线设置点数,2:根据盈亏线设置比例)
input int    take_profit1 = 676; //固定盈利点数
input int    take_profit2 =89;  //根据盈亏线设置的点数
input double profit_ratio = 0.3; //根据盈亏线设置的盈利比例
input int    loss_mode =1;     //止损模式(0:固定止损,1:追迹止损,2:无止损)
input int    stop_loss = 1000;  //固定止损点数
input int    trail_start = 339; //追迹止损开始
input int    trail_stop = 286;  //追迹止损点数
input int    magic_no = 20170128;   //魔术识别号

//对冲顺势加仓
input bool   hedge_enable =true; //对冲开启
input double trend_basic_lots = 0.01; //基础手数
input int    trend_basic_balance = 10000; //基础余额
input int    trend_lots_mode = 0;     //仓位模型(0:使用基础手数,1:根据余额复利)
input int    trend_add_mode =0;      //加仓模型(0:等比加仓,1:等差加仓)
input double trend_lots_multiple =1.2;  //等比加仓倍数
input double trend_lots_increment = 1.0; //基于基础手数等差加仓比例
input int    trend_max_trade = 10; //最大开单量
input int    trend_basic_pip =136;      //基础间距
input int    trend_pip_mode = 0;         //间距模型(0:使用固定间距,1:根据高低点计算,2:根据开仓次数等比增加,3:根据开仓次数等差增加)
input double trend_pip_multiple = 1.6; //等比加距倍数
input double trend_pip_increment = 0.2;  //基于基础间距等差加距比例
input int    trend_profit_mode = 1;    //止盈模式(0:固定设置,1:根据盈亏线设置点数,2:根据盈亏线设置比例3:不止盈)
input int    trend_take_profit1 =606; //固定盈利点数
input int    trend_take_profit2 =686;  //根据盈亏线设置的点数
input double trend_profit_ratio = 0.45; //根据盈亏线设置的盈利比例
input bool   trend_expire_mode=FALSE;//顺势首单消亡判断(True 做消亡判断；False 不做消亡判断)
input int    trend_expire_time =96;   //顺势首单消亡时间（H）
input bool   trend_m_profit_enable =false; //顺势最小盈利比例开启
input double trend_m_profit_ratio = 0.51;    //根据盈亏线设置的最小盈利比例
input int    trend_loss_mode =1;     //止损模式(0:固定止损,1:追迹止损,2:无止损)
input int    trend_stop_loss = 303;  //固定止损点数
input int    trend_trail_start = 392; //追迹止损开始
input int    trend_trail_stop =326; //追迹止损点数
input int    trend_magic_no = 20170228;//魔术识别号

//策略三参数
input bool   strategy3_enable =true; //策略3准备开启
//input int    strategy3_lots_mode = 0;     //仓位模型(0:使用基础手数,1:根据之前策略风险确定)
//input double strategy3_basic_lots = 0.01; //基础手数
//input double strategy3_lots_multiple = 1.8; //等比加仓倍数
//input int    strategy3_basic_pip = 189;     //基础间距
//input int    strategy3__take_profit2 = 50;  //根据盈亏线设置的止盈点数

input double strategy3_risk_value = 0.017; //风控3介入的风险系数(相对于余额)
input double strategy3_hedge_ratio = 1; //风控3对冲头寸的比例
input int    strategy3_magic_no = 20170328;   //魔术识别号

//资金管理:
input int mm_mode = 2; //资金管理模式(0:无管理,1:只支持盈利目标模式,2:只支持总体亏损平仓,3:盈利目标模式和总体亏损平仓)
input int profit_period = 0; //盈利目标周期(0:天,1:周,2:月3:季,4:半年,5:年)
input int profit_target = 1000; //盈利目标金额
input int risk_mode = 1; //风险控制模式(0:浮亏止损,1:浮亏余额比例止损)
input double risk_value1 = 880;   //允许最大浮亏
input double risk_value2 = 0.02386; //风险系数(相对于余额)
      double	DDBuffer = 0;
      double	DDBuffer_Percent = 0;

//开仓时间限定:
//input datetime close_trade_begin1 = 0; //限制交易时段1开始
//input datetime close_trade_end1 = 0; //限制交易时段1结束
//input datetime close_trade_begin2 = 0; //限制交易时段1开始
//input datetime close_trade_end2 = 0; //限制交易时段1结束
//input datetime close_trade_begin3 = 0; //限制交易时段1开始
//input datetime close_trade_end3 = 0; //限制交易时段1结束
//input int hold_time = 96; //持仓时间限定(按小时计)
input datetime dead_line = 0; //EA使用期限
string tc="TOEASY6.0";//工商注释
string txt="http://www.58boc.com";//网站
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   ParaInit(false);
   EventSetTimer(60);
   OrderCloseQueueInit();
   CreateButtons();
   bocun1();
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   ObjectsDeleteAll();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   money_manage(magic_no,trend_magic_no,strategy3_magic_no);
   toEasyMartin(magic_no);
   toEasyHedge(trend_magic_no);
   toEasystrategy3(strategy3_magic_no);
   
//最大跌幅计算
   double DD = AccountBalance() - AccountEquity();
	double DD_Percent = ND((AccountBalance() - AccountEquity()) / AccountBalance() * 100,1);
	if(DD > DDBuffer) DDBuffer = DD;
	if(DD_Percent > DDBuffer_Percent) DDBuffer_Percent = DD_Percent;
bocun();
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      double martinLotsBuy = OrdersLotsBy(OP_BUY,"",magic_no);
      double martinLotsSel = OrdersLotsBy(OP_SELL,"",magic_no);
      double hedgeLotsBuy = OrdersLotsBy(OP_BUY,"",trend_magic_no);
      double hedgeLotsSel = OrdersLotsBy(OP_SELL,"",trend_magic_no);
      double buyLotsAll = martinLotsBuy + hedgeLotsBuy;
      double selLotsAll = martinLotsSel + hedgeLotsSel;

      if(sparam==("open_buy"))
      {
         if(true==GetButtonState("open_buy"))
         {
            SetButtonState("open_buy",false);
            if(selLotsAll>buyLotsAll)
            {
               if(OrdersTotalBy(OP_BUY,"",strategy3_magic_no)<=0)
                  myBuy(selLotsAll-buyLotsAll,"TO-EASY-S3BUY",strategy3_magic_no);
            }
            else
               Alert("多单头寸大于等于空单头寸！");
         }
      }
      if(sparam==("open_sel"))
      {
         if(true==GetButtonState("open_sel"))
         {
            SetButtonState("open_sel",false);
            if(buyLotsAll>selLotsAll)
            {
               if(OrdersTotalBy(OP_SELL,"",strategy3_magic_no)<=0)
                  mySel(buyLotsAll-selLotsAll,"TO-EASY-S3SEL",strategy3_magic_no);
            }
            else
               Alert("空单头寸大于等于多单头寸！");
         }
      }
      if(sparam==("clse_buy"))
      {
         if(true==GetButtonState("clse_buy"))
         {
            SetButtonState("clse_buy",false);
            int buyS3Total = OrdersTotalBy(OP_BUY,"",strategy3_magic_no);
            if(buyS3Total>0)
               CloseAll(OP_BUY,"",strategy3_magic_no);
            else
               Alert("没有对冲做多的单子可平！");
         }
      }
      if(sparam==("clse_sel"))
      {
         if(true==GetButtonState("clse_sel"))
         {
            SetButtonState("clse_sel",false);
            int selS3Total = OrdersTotalBy(OP_SELL,"",strategy3_magic_no);
            if(selS3Total>0)
               CloseAll(OP_SELL,"",strategy3_magic_no);
            else
               Alert("没有对冲做空的单子可平！");
         }
      }
      if(sparam==("clse_all"))
      {
         if(true==GetButtonState("clse_all"))
         {
            SetButtonState("clse_all",false);
            SetButtonState("renew_ea",false);
            gEAStart = false;
            ObjectSetInteger(0,"clse_all",OBJPROP_BGCOLOR,C'236,233,216');
            ObjectSetInteger(0,"renew_ea",OBJPROP_BGCOLOR,C'236,233,216');
            CloseAll(-1,"",magic_no);
            CloseAll(-1,"",trend_magic_no);
            CloseAll(-1,"",strategy3_magic_no);
            Alert("EA已停，若要继续交易，请重新加载或点击自动交易！");
         }
      }
      if(sparam==("renew_ea"))
      {
         if(true==GetButtonState("renew_ea")) {
            ObjectSetInteger(0,"renew_ea",OBJPROP_BGCOLOR,C'180,180,255');
            gEAStart = true;
            Alert("您已启动了EA自动交易！");
         }
         else {
            ObjectSetInteger(0,"renew_ea",OBJPROP_BGCOLOR,C'236,233,216');
            gEAStart = false;
            Alert("您已禁止了EA自动交易！");
         }
      }
   }
  }
//+------------------------------------------------------------------+


bool gEAStart = true;
//+------------------------------------------------------------------+
//| toEasyMartin function : 启动马丁策略的实例
//|   int magic     : 魔术数 用于标识和管理实例
//|   返回值 : -1
//+------------------------------------------------------------------+
int toEasyMartin(int magic)
 {
   //+下单策略-------------------------------------------------------+
   if(gEAStart&&buy_enable&&martin_enable&&checkClosingOrdersCnt(-1)<=0)
   {
      //Bull 多方向实例
      int buyCnt = OrdersTotalBy(OP_BUY,"",magic);
      buyCnt++;
      if(buyCnt==1)
      {
         string comStr = "TO-EASY-Bu"+IntegerToString(buyCnt,2,'0')+" #"+IntegerToString(GetTickCount(),10,'0');
         if(buyMartinCheck(buyCnt,magic)) myBuy(iLotsMartinBy(buyCnt),comStr,magic);
      }
      else if(buyCnt>1&&buyCnt<=max_trade)
      {
         string comStr = "TO-EASY-Bu"+IntegerToString(buyCnt,2,'0')+" #"+IntegerToString(GetTickCount(),10,'0');
         double price_gap_lst = OrderPriceBy(OP_BUY,buyCnt-2,"",magic) - Ask;
         if(price_gap_lst>iPipMartinBy(buyCnt)*Point)
         {
            if(buyMartinCheck(buyCnt,magic)) myBuy(iLotsMartinBy(buyCnt),comStr,magic);
         }
      }
   }
   if(gEAStart&&sel_enable&&martin_enable&&checkClosingOrdersCnt(-1)<=0)
   {
      //Bear 空方向实例
      int selCnt = OrdersTotalBy(OP_SELL,"",magic);
      selCnt++;
      if(selCnt==1)
      {
         string comStr = "TO-EASY-Be"+IntegerToString(selCnt,2,'0')+" #"+IntegerToString(GetTickCount(),10,'0');
         if(selMartinCheck(selCnt,magic)) mySel(iLotsMartinBy(selCnt),comStr,magic);
      }
      else if(selCnt>1&&selCnt<=max_trade)
      {
         string comStr = "TO-EASY-Be"+IntegerToString(selCnt,2,'0')+" #"+IntegerToString(GetTickCount(),10,'0');
         double price_gap_lst = Bid - OrderPriceBy(OP_SELL,selCnt-2,"",magic);
         if(price_gap_lst>iPipMartinBy(selCnt)*Point)
         {
            if(selMartinCheck(selCnt,magic)) mySel(iLotsMartinBy(selCnt),comStr,magic);
         }
      }
   }

   //+平仓策略-------------------------------------------------------+
   int buyTotal = OrdersTotalBy(OP_BUY,"",magic);
   int selTotal = OrdersTotalBy(OP_SELL,"",magic);
   double price_avr_buy = HoldingOrderAvgPrice(OP_BUY,"",magic);
   double price_avr_sel = HoldingOrderAvgPrice(OP_SELL,"",magic);
   if(checkClosingOrdersCnt(-1)<=0)
   {
      {
         //int buyTotal = OrdersTotalBy(OP_BUY,"",magic);
         double price_fst = OrderPriceBy(OP_BUY,0,"",magic);
         double price_lst = OrderPriceBy(OP_BUY,buyTotal-1,"",magic);
         double lots_fst = OrderLotsBy(OP_BUY,0,"",magic);
         double lots_lst = OrderLotsBy(OP_BUY,buyTotal-1,"",magic);
         int ticket_fst = OrderTicketBy(OP_BUY,0,"",magic);
         int ticket_lst = OrderTicketBy(OP_BUY,buyTotal-1,"",magic);
         if(buyTotal==0)
            ObjectDelete("buyAvgPrice");
         if(buyTotal==1)
         {
            double price_close = getBuyClosePrice(price_lst,price_lst,buyTotal,magic);
            if(Bid>price_close)
               myOrderCloseBy(ticket_fst,lots_fst,magic);
            ObjectDelete("buyAvgPrice");
         }
         else if(buyTotal>1&&price_fst>price_lst)
         {
            //double price_avr_buy = HoldingOrderAvgPrice(OP_BUY,"",magic);
            CreatLine("buyAvgPrice",price_avr_buy,clrYellow);
            double price_close = getBuyClosePrice(price_lst,price_avr_buy,buyTotal,magic);
            if(Bid>price_close)
               CloseAll(OP_BUY,"",magic);
         }
      }
      {
         //int selTotal = OrdersTotalBy(OP_SELL,"",magic);
         double price_fst = OrderPriceBy(OP_SELL,0,"",magic);
         double price_lst = OrderPriceBy(OP_SELL,selTotal-1,"",magic);
         double lots_fst = OrderLotsBy(OP_SELL,0,"",magic);
         double lots_lst = OrderLotsBy(OP_SELL,selTotal-1,"",magic);
         int ticket_fst = OrderTicketBy(OP_SELL,0,"",magic);
         int ticket_lst = OrderTicketBy(OP_SELL,selTotal-1,"",magic);
         if(selTotal==0)
            ObjectDelete("selAvgPrice");
         if(selTotal==1)
         {
            double price_close = getSelClosePrice(price_lst,price_lst,selTotal,magic);
            if(Ask<price_close)
               myOrderCloseBy(ticket_fst,lots_fst,magic);
            ObjectDelete("selAvgPrice");
         }
         else if(selTotal>1&&price_fst<price_lst)
         {
            //double price_avr_sel = HoldingOrderAvgPrice(OP_SELL,"",magic);
            CreatLine("selAvgPrice",price_avr_sel,clrBlue);
            double price_close = getSelClosePrice(price_lst,price_avr_sel,selTotal,magic);
            if(Ask<price_close)
               CloseAll(OP_SELL,"",magic);
         }
      }
   }
   if(checkClosingOrdersCnt(-1)<=0)
   {
      //追踪止损:
      if((loss_mode==1)&&price_avr_buy>0&&buyTotal>0)
         TrailingStopAll(OP_BUY,"",magic,price_avr_buy,trail_stop,trail_start);
      if((loss_mode==1)&&price_avr_sel>0&&selTotal>0)
         TrailingStopAll(OP_SELL,"",magic,price_avr_sel,trail_stop,trail_start);
   }

   //+执行平仓-------------------------------------------------------+
   OrderCloseProcess(-1);
   
   return -1;
 }

double HoldingOrderAvgPrice(int opType, string comment, int magic)
 {
   double Tmp=0;
   double TotalLots=0;
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      bool ret = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(ret&&(OrderSymbol()==Symbol())&&
                  (OrderType()==opType)&&(OrderMagicNumber()==magic))
      {
         Tmp+=OrderOpenPrice()*OrderLots();
         TotalLots+=OrderLots();
      }
   }
   if(TotalLots<=0)
      return 0;
   return (Tmp/TotalLots);
 }

/*
input int    profit_mode = 0;    //止盈模式(0:固定设置,1:根据盈亏线设置点数,2:根据盈亏线设置比例)
input double take_profit1 = 200; //固定盈利点数
input double take_profit2 = 50;  //根据盈亏线设置的点数
input double profit_ratio = 0.1; //根据盈亏线设置的盈利比例
input int    loss_mode = 0;     //止损模式(0:固定止损,1:追迹止损)
input int    stop_loss = 1000;  //固定止损点数
input int    trail_start = 200; //追迹止损开始
input int    trail_stop = 100;  //追迹止损点数
*/
double getBuyClosePrice(double price_lst, double price_avr, int trade_num, int magic)
 {
   double closePrice = 10000;
   if(trade_num==1)
      closePrice = price_lst + take_profit1*Point;
   else if(trade_num>=2)
   {
      if(profit_mode==0)
         closePrice = price_lst + take_profit1*Point;
      else if(profit_mode==1)
         closePrice = price_avr + take_profit2*Point;
      else if(profit_mode==2)
         closePrice = price_avr + (price_avr-price_lst)*profit_ratio*Point;
   }
   return closePrice;
 }
double getSelClosePrice(double price_lst, double price_avr, int trade_num, int magic)
 {
   double closePrice = 0;
   if(trade_num==1)
      closePrice = price_lst - take_profit1*Point;
   else if(trade_num>=2)
   {
      if(profit_mode==0)
         closePrice = price_lst - take_profit1*Point;
      else if(profit_mode==1)
         closePrice = price_avr - take_profit2*Point;
      else if(profit_mode==2)
         closePrice = price_avr - (price_lst - price_avr)*profit_ratio*Point;
   }
   return closePrice;
 }

void CreatLine(string objName,double Data,color Cl)
{
  ObjectDelete(objName);
  ObjectCreate(objName,OBJ_HLINE,0,TimeCurrent(),Data); 
  ObjectSet(objName,OBJPROP_COLOR,Cl);
  ObjectSet(objName,OBJPROP_STYLE,STYLE_DASHDOTDOT);
}

void CloseAll(int opType, string comment, int magic)
{
   int total=OrdersTotal();
   for(int i=total-1;i>=0;i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
      {
         if(checkConditionBy(opType,comment,magic))
            myOrderCloseBy(OrderTicket(),OrderLots(),magic);
      }
   }
}

/*
input double basic_lots = 0.01; //基础手数
input int    basic_balance = 10000; //基础余额
input int    lots_mode = 0;     //仓位模型(0:使用基础手数,1:根据余额复利)
input int    add_mode = 0;      //加仓模型(0:等比加仓,1:等差加仓)
input double lots_multiple = 2.0;  //等比加仓倍数
input double lots_increment = 1.0; //基于基础手数等差加仓比例
input int    max_trade = 10; //最大开单量
*/
double iLotsMartinBy(int index)
 {
   double iLots=0;
   double iLotsBasic=0;
   if(index<1||index>max_trade)
      return 0;
   if(lots_mode == 0)
      iLotsBasic = basic_lots;
   else if(lots_mode == 1)
      iLotsBasic = basic_lots*((int)(AccountBalance()/basic_balance)+1);
   if(add_mode==0)
      iLots = 0.01*(int)(100*iLotsBasic*MathPow(lots_multiple,index-1));
   else if(add_mode==1)
      iLots = 0.01*(int)(100*iLotsBasic*(1+lots_increment*(index-1)));
   return iLots;
 }

/*
input int    basic_pip = 156;      //基础间距
input int    pip_mode = 0;         //间距模型(0:使用固定间距,1:根据高低点计算,2:根据开仓次数等比增加,3:根据开仓次数等差增加)
input double pip_multiple = 1.618; //等比加距倍数
input double pip_increment = 0.2;  //基于基础间距等差加距比例
*/
int iPipMartinBy(int index)
 {
   int iPip = 0;
   if(index<2||index>max_trade)
      return 0;
   if(pip_mode==0)
      iPip = basic_pip;
   else if(pip_mode==1)
   {}
   else if(pip_mode==2)
      iPip = int(basic_pip*MathPow(pip_multiple,index-2));
   else if(pip_mode==3)
      iPip = int(basic_pip*(1+pip_increment*(index-2)));
   return iPip;
 }

input bool     上布林检查开启=True;
input bool     下布林检查开启=True;
input int      布林通道周期_H=48;
input double   布林通道偏差=1.5;
input bool     AC指标为正不做空=True;
input bool     AC指标为负不做多=True;
input int      马丁连续开单时间间隔_分=1;

input bool     布林上轨开外对冲不做空=False;
input bool     布林下轨开外对冲不做多=false;
input bool     布林中轨附近对冲不做单=false;
input double   布林中轨过滤偏差=1;

bool buyMartinCheck(int buyNxtTotal, int magic)
 {
   double Open1=iOpen (NULL, PERIOD_M15, 1);
   double Close1=iClose(NULL, PERIOD_M15, 1);
   double iRsi0 = iRSI(NULL,PERIOD_M5,14,PRICE_CLOSE,0); 
   double iRsi1 = iRSI(NULL,PERIOD_D1,14,PRICE_CLOSE,0); 
   if(下布林检查开启&&(insideBollingerBand(布林通道周期_H,布林通道偏差)==2))
      return false;
   if(AC指标为负不做多&&(iAC(NULL,PERIOD_M15,0)<0))
      return false;

   //马丁连续开单时间限制
   datetime buyLastTime = OrdersLastTime(OP_BUY,"",magic);
   if((TimeCurrent()-buyLastTime)<60*马丁连续开单时间间隔_分)
      return false;

   //TODO: 其他判断
     if(buyNxtTotal==1)
   {
      if(!((iRsi1<30||(iRsi0>51&&iRsi0<70))&&Open1<Close1))
         return false;
   }

   return true;
 }

bool selMartinCheck(int selNxtTotal, int magic)
 {
   double Open1=iOpen (NULL, PERIOD_M15, 1);
   double Close1=iClose(NULL, PERIOD_M15, 1);
   double iRsi0 = iRSI(NULL,PERIOD_M5,14,PRICE_CLOSE,0); 
   double iRsi1 = iRSI(NULL,PERIOD_D1,14,PRICE_CLOSE,0); 
   if(上布林检查开启&&(insideBollingerBand(布林通道周期_H,布林通道偏差)==1))
      return false;
   if(AC指标为正不做空&&(iAC(NULL,PERIOD_M15,0)>0))
      return false;

   //马丁连续开单时间限制
   datetime selLastTime = OrdersLastTime(OP_SELL,"",magic);
   if((TimeCurrent()-selLastTime)<60*马丁连续开单时间间隔_分)
      return false;

   //TODO: 其他判断
     if(selNxtTotal==1)
   {
      if(!((iRsi1>70||(iRsi0<49&&iRsi0>30))&&Open1>Close1))
         return false;
   }

   return true;
 }

int insideBollingerBand(int period, double deviation)
{
   double bandsH = iBands(NULL,PERIOD_H1,period,deviation,0,PRICE_CLOSE,MODE_UPPER,0);
   double bandsL = iBands(NULL,PERIOD_H1,period,deviation,0,PRICE_CLOSE,MODE_LOWER,0);
   if(Ask>bandsH)
      return 1;
   if(Bid<bandsL)
      return 2;
   return 0;
}

//+------------------------------------------------------------------+
//| toEasyHedge function : 启动顺势策略的实例
//|   int magic     : 魔术数 用于标识和管理实例
//|   返回值 : -1
//+------------------------------------------------------------------+
int toEasyHedge(int magic)
 {
   //+下单策略-------------------------------------------------------+
   if(gEAStart&&hedge_enable&&checkClosingOrdersCnt(-1)<=0)
   {
      //Bull 多方向实例
      int buyCnt = OrdersTotalBy(OP_BUY,"",magic);
      buyCnt++;
      if(buyCnt==1)
      {
         string comStr = "TO-EASY-Bu"+IntegerToString(buyCnt+50,2,'0')+" #"+IntegerToString(GetTickCount(),10,'0');
         if(buyHedgeCheck(buyCnt,magic)) myBuy(iLotsHedgeBy(buyCnt),comStr,magic);
      }
      else if(buyCnt>1&&buyCnt<=trend_max_trade)
      {
         string comStr = "TO-EASY-Bu"+IntegerToString(buyCnt+50,2,'0')+" #"+IntegerToString(GetTickCount(),10,'0');
         double price_gap_lst = Ask - OrderPriceBy(OP_BUY,0,"",magic);
         if(price_gap_lst>iPipHedgeBy(buyCnt)*Point)
         {
            if(buyHedgeCheck(buyCnt,magic)) myBuy(iLotsHedgeBy(buyCnt),comStr,magic);
         }
      }
   }
   if(gEAStart&&hedge_enable&&checkClosingOrdersCnt(-1)<=0)
   {
      //Bear 空方向实例
      int selCnt = OrdersTotalBy(OP_SELL,"",magic);
      selCnt++;
      if(selCnt==1)
      {
         string comStr = "TO-EASY-Be"+IntegerToString(selCnt+50,2,'0')+" #"+IntegerToString(GetTickCount(),10,'0');
         if(selHedgeCheck(selCnt,magic)) mySel(iLotsHedgeBy(selCnt),comStr,magic);
      }
      else if(selCnt>1&&selCnt<=trend_max_trade)
      {
         string comStr = "TO-EASY-Be"+IntegerToString(selCnt+50,2,'0')+" #"+IntegerToString(GetTickCount(),10,'0');
         double price_gap_lst = OrderPriceBy(OP_SELL,0,"",magic) - Bid;
         if(price_gap_lst>iPipHedgeBy(selCnt)*Point)
         {
            if(selHedgeCheck(selCnt,magic)) mySel(iLotsHedgeBy(selCnt),comStr,magic);
         }
      }
   }

   //+平仓策略-------------------------------------------------------+
   int buyTotal = OrdersTotalBy(OP_BUY,"",magic);
   int selTotal = OrdersTotalBy(OP_SELL,"",magic);
   double price_avr_buy = HoldingOrderAvgPrice(OP_BUY,"",magic);
   double price_avr_sel = HoldingOrderAvgPrice(OP_SELL,"",magic);
   if(checkClosingOrdersCnt(-1)<=0)
   {
      {
         //int buyTotal = OrdersTotalBy(OP_BUY,"",magic);
         double price_fst = OrderPriceBy(OP_BUY,buyTotal-1,"",magic);
         double price_lst = OrderPriceBy(OP_BUY,0,"",magic);
         double lots_fst = OrderLotsBy(OP_BUY,buyTotal-1,"",magic);
         //double lots_lst = OrderLotsBy(OP_BUY,0,"",magic);
         int ticket_fst = OrderTicketBy(OP_BUY,buyTotal-1,"",magic);
         //int ticket_lst = OrderTicketBy(OP_BUY,0,"",magic);
         if(buyTotal==0)
            ObjectDelete("buyHedgeAvgPrice");
         if(buyTotal==1)
         {
            //if((price_fst - Bid)>getHedgeProfitPoint(buyTotal,magic)*Point)
               //myOrderCloseBy(ticket_fst,lots_fst,magic);
            datetime openTime = OrderOpenTimeBy(ticket_fst);
            if( trend_expire_mode==True){
            if((TimeCurrent()-openTime)>(trend_expire_time*60*60))
               myOrderCloseBy(ticket_fst,lots_fst,magic);}
            ObjectDelete("buyHedgeAvgPrice");
         }
         else if(buyTotal>1&&price_fst<price_lst)
         {
            //double price_avr_buy = HoldingOrderAvgPrice(OP_BUY,"",magic);
            CreatLine("buyHedgeAvgPrice",price_avr_buy,clrDarkOrchid);
            
            if((trend_profit_mode==1)&&(Bid>(price_avr_buy+trend_take_profit2*Point)))
               CloseAll(OP_BUY,"",magic);
            else if((Bid - price_avr_buy) < (price_lst - price_avr_buy)*trend_m_profit_ratio)
               if(trend_m_profit_enable) CloseAll(OP_BUY,"",magic);
         }
      }
      {
         //int selTotal = OrdersTotalBy(OP_SELL,"",magic);
         double price_fst = OrderPriceBy(OP_SELL,selTotal-1,"",magic);
         double price_lst = OrderPriceBy(OP_SELL,0,"",magic);
         double lots_fst = OrderLotsBy(OP_SELL,selTotal-1,"",magic);
         //double lots_lst = OrderLotsBy(OP_SELL,0,"",magic);
         int ticket_fst = OrderTicketBy(OP_SELL,selTotal-1,"",magic);
         //int ticket_lst = OrderTicketBy(OP_SELL,0,"",magic);
         if(selTotal==0)
            ObjectDelete("selHedgeAvgPrice");
         if(selTotal==1)
         {
            //if((Ask - price_fst)>getHedgeProfitPoint(selTotal,magic)*Point)
               //myOrderCloseBy(ticket_fst,lots_fst,magic);
            datetime openTime = OrderOpenTimeBy(ticket_fst);
            if( trend_expire_mode==True){
            if((TimeCurrent()-openTime)>(trend_expire_time*60*60))
               myOrderCloseBy(ticket_fst,lots_fst,magic);}
            ObjectDelete("selHedgeAvgPrice");
         }
         else if(selTotal>1&&price_fst>price_lst)
         {
            //double price_avr_sel = HoldingOrderAvgPrice(OP_SELL,"",magic);
            CreatLine("selHedgeAvgPrice",price_avr_sel,clrSalmon);

            if((trend_profit_mode==1)&&(Ask<(price_avr_buy-trend_take_profit2*Point)))
               CloseAll(OP_SELL,"",magic);
            else if((price_avr_sel - Ask) < (price_avr_sel - price_lst)*trend_m_profit_ratio)
               if(trend_m_profit_enable) CloseAll(OP_SELL,"",magic);
         }
      }
   }
   if(checkClosingOrdersCnt(-1)<=0)
   {
      //追踪止损:
      if((trend_loss_mode==1)&&price_avr_buy>0&&buyTotal>1)
         TrailingStopAllByEA(OP_BUY,"",magic,price_avr_buy,trend_trail_stop,trend_trail_start);
      if((trend_loss_mode==1)&&price_avr_sel>0&&selTotal>1)
         TrailingStopAllByEA(OP_SELL,"",magic,price_avr_sel,trend_trail_stop,trend_trail_start);
   }
   
   //+执行平仓-------------------------------------------------------+
   OrderCloseProcess(-1);

   return -1;
 }

/*
input double trend_basic_lots = 0.01; //基础手数
input int    trend_basic_balance = 10000; //基础余额
input int    trend_lots_mode = 0;     //仓位模型(0:使用基础手数,1:根据余额复利)
input int    trend_add_mode = 0;      //加仓模型(0:等比加仓,1:等差加仓)
input double trend_lots_multiple = 2.0;  //等比加仓倍数
input double trend_lots_increment = 1.0; //基于基础手数等差加仓比例
input int    trend_max_trade = 10; //最大开单量
*/
double iLotsHedgeBy(int index)
 {
   double iLots=0;
   double iLotsBasic=0;
   if(index<1||index>trend_max_trade)
      return 0;
   if(trend_lots_mode == 0)
      iLotsBasic = trend_basic_lots;
   else if(trend_lots_mode == 1)
      iLotsBasic = trend_basic_lots*((int)(AccountBalance()/trend_basic_balance)+1);
   if(trend_add_mode==0)
      iLots = 0.01*(int)(100*iLotsBasic*MathPow(trend_lots_multiple,index-1));
   else if(trend_add_mode==1)
      iLots = 0.01*(int)(100*iLotsBasic*(1+trend_lots_increment*(index-1)));
   return iLots;
 }

/*
input int    trend_basic_pip = 156;      //基础间距
input int    trend_pip_mode = 0;         //间距模型(0:使用固定间距,1:根据高低点计算,2:根据开仓次数等比增加,3:根据开仓次数等差增加)
input double trend_pip_multiple = 1.618; //等比加距倍数
input double trend_pip_increment = 0.2;  //基于基础间距等差加距比例
*/
int iPipHedgeBy(int index)
 {
   int iPip = 0;
   if(index<2||index>trend_max_trade)
      return 0;
   if(trend_pip_mode==0)
      iPip = trend_basic_pip;
   else if(trend_pip_mode==1)
   {}
   else if(trend_pip_mode==2)
      iPip = int(trend_basic_pip*MathPow(trend_pip_multiple,index-2));
   else if(trend_pip_mode==3)
      iPip = int(trend_basic_pip*(1+trend_pip_increment*(index-2)));
   return iPip;
 }

/*
input bool     布林上轨开外对冲不做空=True;
input bool     布林下轨开外对冲不做多=True;
input bool     布林中轨附近对冲不做单=True;
input double   布林中轨过滤偏差=0.5;
*/
bool buyHedgeCheck(int buyNxtTotal, int magic)
 {
    double iC1 = iClose(NULL,PERIOD_H1,1);
    double iC2 = iClose(NULL,PERIOD_H1,2);
    double iRsi0 = iRSI(NULL,PERIOD_H4,14,PRICE_CLOSE,0);
    double iRsi1 = iRSI(NULL,PERIOD_D1,14,PRICE_CLOSE,0);
    //double cci_01 = iCCI(Symbol(),PERIOD_D1,14,PRICE_CLOSE,0); 
    //double cci_02 = iCCI(Symbol(),PERIOD_H1,14,PRICE_CLOSE,0);     
    //double Mymacd0=iMACD(NULL,PERIOD_D1,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
	 //double Mymacd1=iMACD(NULL,PERIOD_D1,12,26,9,PRICE_CLOSE,MODE_MAIN,1);  
	 if(AC指标为负不做多&&(iAC(NULL,PERIOD_H1,0)<0))
      return false;
   
   if(布林下轨开外对冲不做多&&(insideBollingerBand(布林通道周期_H,布林通道偏差)==2))
      return false;

   if(布林中轨附近对冲不做单&&(insideBollingerBand(布林通道周期_H,布林中轨过滤偏差)==0))
      return false;

   //TODO: 其他判断
 
     if(buyNxtTotal==1)
   {
      if(!(iC1>iC2&&(iRsi1>70||(iRsi0>50&&iRsi0<70))))
         return false;
   }

   return true;
 }

bool selHedgeCheck(int selNxtTotal, int magic)
 {    double iC1 = iClose(NULL,PERIOD_H1,1);
      double iC2 = iClose(NULL,PERIOD_H1,2);
      double iRsi0 = iRSI(NULL,PERIOD_H4,14,PRICE_CLOSE,0);
      double iRsi1= iRSI(NULL,PERIOD_D1,14,PRICE_CLOSE,0);
     // double cci_01 = iCCI(Symbol(),PERIOD_D1,14,PRICE_CLOSE,0); 
     // double cci_02 = iCCI(Symbol(),PERIOD_H1,14,PRICE_CLOSE,0); 
     // double Mymacd0=iMACD(NULL,PERIOD_D1,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
	   //double Mymacd1=iMACD(NULL,PERIOD_D1,12,26,9,PRICE_CLOSE,MODE_MAIN,1);  
   if(AC指标为正不做空&&(iAC(NULL,PERIOD_H1,0)>0))
      return false;
   if(布林上轨开外对冲不做空&&(insideBollingerBand(布林通道周期_H,布林通道偏差)==1))
      return false;
   if(布林中轨附近对冲不做单&&(insideBollingerBand(布林通道周期_H,布林中轨过滤偏差)==0))
      return false;
   //TODO: 其他判断
     if(selNxtTotal==1)
   {
      if(!(iC1<iC2&&(iRsi1<30||(iRsi0<49&&iRsi0>30))))
          return false;
   }

   return true;
 }
//*以下是AI技术参数
/*
 int    x1 = 120;
 int    x2 = 172;
 int    x3 = 39;
 int    x4 = 172;
 double perceptron() 
  {
   double w1 = x1 - 100;
   double w2 = x2 - 100;
   double w3 = x3 - 100;
   double w4 = x4 - 100;
   double a1 = iAC(Symbol(), 0, 0);
   double a2 = iAC(Symbol(), 0, 7);
   double a3 = iAC(Symbol(), 0, 14);
   double a4 = iAC(Symbol(), 0, 21);
   return(w1 * a1 + w2 * a2 + w3 * a3 + w4 * a4);
  }

*/
/*
input int    trend_profit_mode = 0;    //止盈模式(0:固定设置,1:根据盈亏线设置点数,2:根据盈亏线设置比例)
input double trend_take_profit1 = 200; //固定盈利点数
input double trend_take_profit2 = 50;  //根据盈亏线设置的点数
input double trend_profit_ratio = 0.01; //根据盈亏线设置的盈利比例
input int    trend_loss_mode = 1;     //止损模式(0:固定止损,1:追迹止损,2:无止损)
input double trend_stop_loss = 1000;  //固定止损点数
input double trend_trail_start = 200; //追迹止损开始
input double trend_trail_stop = 100;  //追迹止损点数
*/
int getHedgeProfitPoint(int trade_num, int magic)
 {
   int iPoint = 0;
   if(trade_num==1)
      iPoint = trend_basic_pip;
   return iPoint;
 }

int myBuy(const double Lots, const string comment, const int magic)
 {
   bool exist = false;
   int total = OrdersTotal();
   for(int i=0;i<total;i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if((OrderSymbol()==Symbol())&&(OrderType()==OP_BUY)&&
            (OrderComment()==comment)&&(OrderMagicNumber()==magic))
            exist = true;
      }
   }
   if(exist||Lots<0.01) return -1; //订单已存在
   int ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask,30,0,0,comment,magic,0,clrBlue);
   return ticket;
 }
 
int mySel(const double Lots, const string comment, const int magic)
 {
   bool exist = false;
   int total = OrdersTotal();
   for(int i=0;i<total;i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if((OrderSymbol()==Symbol())&&(OrderType()==OP_SELL)&&
            (OrderComment()==comment)&&(OrderMagicNumber()==magic))
            exist = true;
      }
   }
   if(exist||Lots<0.01) return -1; //订单已存在
   int ticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,30,0,0,comment,magic,0,clrGreen);
   return ticket;
 }

datetime OrderOpenTimeBy(int ticketBy)
 {
   datetime timeBy = 0;
   if(ticketBy>0&&OrderSelect(ticketBy,SELECT_BY_TICKET,MODE_TRADES))
      timeBy = OrderOpenTime();
   return timeBy;
 }

bool checkConditionBy(int opType, string comment, int magic)
 {
   if((Symbol()==""||OrderSymbol()==Symbol())&&(opType==-1||OrderType()==opType)&&
      (comment==""||OrderComment()==comment)&&(magic==-1||OrderMagicNumber()==magic))
      return true;
   return false;
 }

int OrdersTotalBy(int opType, string comment, int magic)
 {
   int totalBy=0,total=OrdersTotal();
   for(int i=0;i<total;i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
      {
         if(checkConditionBy(opType,comment,magic))
            totalBy++;
      }
   }
   return totalBy;
 }

double OrdersProfitBy(int opType, string comment, int magic)
 {
   int total=OrdersTotal();
   double profitBy = 0;
   for(int i=0;i<total;i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
      {
         if(checkConditionBy(opType,comment,magic))
            profitBy += OrderProfit();
      }
   }
   return profitBy;
 }

double OrdersLotsBy(int opType, string comment, int magic)
 {
   int total=OrdersTotal();
   double lotsBy = 0;
   for(int i=0;i<total;i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
      {
         if(checkConditionBy(opType,comment,magic))
            lotsBy += OrderLots();
      }
   }
   return lotsBy;
 }

datetime OrdersLastTime(int opType, string comment, int magic)
 {
   int total=OrdersTotal();
   datetime lastTime = 0;
   for(int i=0;i<total;i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
      {
         if(checkConditionBy(opType,comment,magic))
         {
            if(lastTime < OrderOpenTime())
               lastTime = OrderOpenTime();
         }
      }
   }
   return lastTime;
 }

//+------------------------------------------------------------------+
//| OrderPriceBy function : 查找逆势计数的第index单的价格
//|   int opType        : 交易类型 "-1"代表不检查
//|   int index         : 顺序号 按照逆操作的顺序排列
//|   string comment    : 注释 用于订单管理标识订单 ""代表不检查
//|   int magic         : 魔术数 用于订单管理标识订单 "-1"代表不检查
//|   返回值 : 符合<货币兑,,,魔术数>四元组特征的第index单(逆势计)的价格
//+------------------------------------------------------------------+
double OrderPriceBy(int opType, int index, string comment, int magic)
 {
   double priceBy = 0;
   int ticketBy = OrderTicketBy(opType,index,comment,magic);
   if(ticketBy>0&&OrderSelect(ticketBy,SELECT_BY_TICKET,MODE_TRADES))
      priceBy = OrderOpenPrice();
   return priceBy;
 }

//+------------------------------------------------------------------+
//| OrderLotsBy function : 查找逆势计数的第index单的手数
//|   int opType        : 交易类型 "-1"代表不检查
//|   int index         : 顺序号 按照逆操作的顺序排列
//|   string comment    : 注释 用于订单管理标识订单 ""代表不检查
//|   int magic         : 魔术数 用于订单管理标识订单 "-1"代表不检查
//|   返回值 : 符合<货币兑,,,魔术数>四元组特征的第index单(逆势计)的手数
//+------------------------------------------------------------------+
double OrderLotsBy(int opType, int index, string comment, int magic)
 {
   double lotsBy = 0;
   int ticketBy = OrderTicketBy(opType,index,comment,magic);
   if(ticketBy>0&&OrderSelect(ticketBy,SELECT_BY_TICKET,MODE_TRADES))
      lotsBy = OrderLots();
   return lotsBy;
 }

//+------------------------------------------------------------------+
//| OrderTicketBy function : 查找逆势计数的第index单的订单号
//|   int opType        : 交易类型 "-1"代表不检查
//|   int index         : 顺序号 按照逆操作的顺序排列
//|   string comment    : 注释 用于订单管理标识订单 ""代表不检查
//|   int magic         : 魔术数 用于订单管理标识订单 "-1"代表不检查
//|   返回值 : 符合<货币兑,,,魔术数>四元组特征的第index单(逆势计)的订单号
//+------------------------------------------------------------------+
#define MAX_SORT_SIZE 64  //最大排序存储空间
int OrderTicketBy(int opType, int index, string comment, int magic)
 {
   int count=0,total=OrdersTotal();
   int ticketBy=0,tickets[MAX_SORT_SIZE]={0};
   double prices[MAX_SORT_SIZE]={0},prices_b[MAX_SORT_SIZE]={0};
   for(int i=0;i<total;i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
      {
         if(checkConditionBy(opType,comment,magic))
         {
            if(count>=MAX_SORT_SIZE)
            {
               Alert("count " + IntegerToString(count) + 
                     " >=MAX_SORT_SIZE !!!");
               return -2;
            }
            tickets[count]=OrderTicket();
            prices[count]=OrderOpenPrice();
            count++;
         }
      }
   }
   if(index<0||index>=count) return -1;
   ArrayCopy(prices_b,prices,0,0,count);
   if(opType==OP_BUY)
      ArraySort(prices,count,0,MODE_DESCEND);
   else if(opType==OP_SELL)
      ArraySort(prices,count,0,MODE_ASCEND);
   for(int i=0;i<count;i++)
   {
      if(prices_b[i]==prices[index])
         ticketBy = tickets[i];
   }
   return ticketBy;
 }


//+------------------------------------------------------------------+
//+平仓管理模块-------------------------------------------------------+

#define MAX_QUEUE_SIZE 64  //OrderCloseQueue的最大存储空间
struct OrderCloseItem
{
   int orderTicket;  //订单编号
   double orderLots; //交易手数
   int magicNumber;  //魔术编号
};
OrderCloseItem OrderCloseQueue[MAX_QUEUE_SIZE];

//+------------------------------------------------------------------+
//| OrderCloseQueueInit function : 初始化平仓环境变量队列列表
//|   返回值 : -1
//|   Note : 该函数拟定在OnInit中被执行
//+------------------------------------------------------------------+
int OrderCloseQueueInit(void)
 {
   for(int i=0;i<MAX_QUEUE_SIZE;i++)
   {
      OrderCloseQueue[i].orderTicket = -1;
      OrderCloseQueue[i].orderLots = 0;
      OrderCloseQueue[i].magicNumber = -1;
   }
   return -1;
 }

//+------------------------------------------------------------------+
//| myOrderCloseBy function : 平仓函数 将需要平仓的订单扔给队列
//|   int ticket        : 订单编号
//|   double Lots       : 平仓手数
//|   int magic         : 魔术数 用于订单管理标识订单
//|   返回值 : 平仓队列的index顺序号，-1，-2
//+------------------------------------------------------------------+
int myOrderCloseBy(int ticket, double Lots, int magic)
 {
   if(ticket<=0||Lots<=0||magic<=0)
      return -2;
   for(int i=0;i<MAX_QUEUE_SIZE;i++)
   {
      if(OrderCloseQueue[i].magicNumber<0)
      {
         OrderCloseQueue[i].orderTicket = ticket;
         OrderCloseQueue[i].orderLots = Lots;
         OrderCloseQueue[i].magicNumber = magic;
         return i;
      }
   }
   return -1;
 }

//+------------------------------------------------------------------+
//| OrderCloseProcess function : 平仓队列管理函数
//|   int magic         : 魔术数 用于订单管理标识订单 "-1"代表不检查
//|   返回值 : 平仓队列的index顺序号，-1，0
//|   Note : 该函数拟定在OnTick中重复执行
//+------------------------------------------------------------------+
int OrderCloseProcess(int magic)
 {
   for(int i=0;i<MAX_QUEUE_SIZE;i++)
   {
      if(OrderCloseQueue[i].orderTicket>0&&OrderCloseQueue[i].orderLots>0&&
        (magic<0||OrderCloseQueue[i].magicNumber==magic))
      {
         if(OrderSelect(OrderCloseQueue[i].orderTicket,
                                      SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderCloseQueue[i].orderLots > OrderLots())
               OrderCloseQueue[i].orderLots = OrderLots();
            if(OrderClose(OrderCloseQueue[i].orderTicket,
               OrderCloseQueue[i].orderLots,OrderClosePrice(),0,clrGreen))
            {
               OrderCloseQueue[i].orderTicket = -1;
               OrderCloseQueue[i].orderLots = 0;
               OrderCloseQueue[i].magicNumber = -1;
               return 0;
            }
            else
            {
               int errCode = GetLastError();
               Alert("Error OrderClose : ticket="+
                     IntegerToString(OrderCloseQueue[i].orderTicket)+
                     ", "+IntegerToString(errCode));
               if(OrderSelect(OrderCloseQueue[i].orderTicket,
                                            SELECT_BY_TICKET,MODE_HISTORY))
               {
                  OrderCloseQueue[i].orderTicket = -1;
                  OrderCloseQueue[i].orderLots = 0;
                  OrderCloseQueue[i].magicNumber = -1;
               }
               return i;
            }
         }
         else
         {
            int errCode = GetLastError();
            Alert("Error OrderSelect : ticket="+
                  IntegerToString(OrderCloseQueue[i].orderTicket)+
                  ", "+IntegerToString(errCode));
         }
         break;
      }
   }
   return -1;
 }

//+------------------------------------------------------------------+
//| checkClosingOrdersCnt function : 检查队列中未被平仓的订单数
//|   int magic         : 魔术数 用于订单管理标识订单 "-1"代表不检查
//|   返回值 : 符合magic的队列中未被平仓的订单数
//+------------------------------------------------------------------+
int checkClosingOrdersCnt(int magic)
 {
   int count = 0;
   for(int i=0;i<MAX_QUEUE_SIZE;i++)
   {
      if(OrderCloseQueue[i].orderTicket>0&&OrderCloseQueue[i].orderLots>0&&
        (magic<0||OrderCloseQueue[i].magicNumber==magic))
            count++;
   }
   return count;
 }

//+------------------------------------------------------------------+
//| myOrderModify function : 修改止盈止损
//|   double stoploss   : 止损价格
//|   double takeprofit : 止盈价格
//|   string comment    : 注释 用于订单管理标识订单
//|   int magic         : 魔术数 用于订单管理标识订单
//|   返回值 : 是否成功
//+------------------------------------------------------------------+
bool myOrderModify(double stoploss, double takeprofit, string comment, int magic)
 {
   bool retVal = true;
   int total = OrdersTotal();
   for(int i=0;i<total;i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if((OrderSymbol()==Symbol())&&
            (comment==""||OrderComment()==comment)&&(OrderMagicNumber()==magic))
         {
            if(stoploss<0)
               stoploss = OrderStopLoss();
            if(takeprofit<0)
               takeprofit = OrderTakeProfit();
            if((stoploss>=0&&OrderStopLoss()!=stoploss)||(takeprofit>=0&&OrderTakeProfit()!=takeprofit))
               retVal = OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,takeprofit,0);
            if(!retVal) break;
         }
      }
   }
   return retVal;
 }

//+------------------------------------------------------------------+
//| TrailingStopAll function : 实例所有订单的追踪止损功能函数
//|   int opType        : 交易类型 "-1"代表不检查
//|   string comment    : 注释 用于订单管理标识订单 ""代表不检查
//|   int magic         : 魔术数 用于订单管理标识订单 "-1"代表不检查
//|   double avrPrice   : 基于平均价格计
//|   int trailingStart : 追踪止损开始点trailingStart和trailingStopLoss
//|   int trailingStopLoss : 追踪止损值
//|   返回值 : 是否成功
//|   Note : 该函数拟定在OnTick中重复执行
//+------------------------------------------------------------------+
bool TrailingStopAll(int opType, string comment, int magic, 
                     double avrPrice, int trailingStopLoss, int trailingStart)
 {
   bool retVal = true;
   int total=OrdersTotal();
   if(avrPrice<=0) return false;
   for(int i=total-1;i>=0;i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(checkConditionBy(opType,comment,magic))
         {
            if(OrderType() == OP_BUY && 
               Bid-Point*trailingStart >= avrPrice && 
               (Bid-Point*trailingStopLoss > OrderStopLoss() || OrderStopLoss()==0)) {
                  retVal = OrderModify(OrderTicket(),OrderOpenPrice(),
                                       Bid-Point*trailingStopLoss,OrderTakeProfit(),0,Aqua);
            }
            else if(OrderType() == OP_SELL && 
               Ask+Point*trailingStart <= avrPrice && 
               (Ask+Point*trailingStopLoss < OrderStopLoss() || OrderStopLoss()==0)) {
                  retVal = OrderModify(OrderTicket(),OrderOpenPrice(),
                                       Ask+Point*trailingStopLoss,OrderTakeProfit(),0,Red);
            }
            if(!retVal) {
               int errCode = GetLastError();
               Alert("Error TrailingStop : ticket="+
                           IntegerToString(OrderTicket())+", "+IntegerToString(errCode));
            }
         }
      }
   }
   return retVal;
 }
double ordersStopLossBuy = 0, ordersStopLossSel = 0;
bool TrailingStopAllByEA(int opType, string comment, int magic, 
                     double avrPrice, int trailingStopLoss, int trailingStart)
 {
   bool retVal = true;
   string STOP_LOSS_LINE = "";

   STOP_LOSS_LINE += Symbol();
   if(opType==OP_BUY)
      STOP_LOSS_LINE += "BUY";
   if(opType==OP_SELL)
      STOP_LOSS_LINE += "SEL";
   if(comment!="")
      STOP_LOSS_LINE += comment;
   STOP_LOSS_LINE += IntegerToString(magic);

   if(opType==OP_BUY&&ordersStopLossBuy<=0)
   {
      if(GlobalVariableCheck(STOP_LOSS_LINE))
         ordersStopLossBuy = GlobalVariableGet(STOP_LOSS_LINE);
   }
   if(opType==OP_SELL&&ordersStopLossSel<=0)
   {
      if(GlobalVariableCheck(STOP_LOSS_LINE))
         ordersStopLossSel = GlobalVariableGet(STOP_LOSS_LINE);
   }

   if(avrPrice<=0) return false;
   
   if(opType == OP_BUY && 
      Bid-Point*trailingStart >= avrPrice && 
      (Bid-Point*trailingStopLoss > ordersStopLossBuy || ordersStopLossBuy==0)) {
      //TODO:更新止损值
      GlobalVariableSet(STOP_LOSS_LINE,Bid-Point*trailingStopLoss);
      ordersStopLossBuy = Bid-Point*trailingStopLoss;
      CreatLine(STOP_LOSS_LINE,Bid-Point*trailingStopLoss,clrBrown);
   }
   else if(opType == OP_SELL && 
      Ask+Point*trailingStart <= avrPrice && 
      (Ask+Point*trailingStopLoss < ordersStopLossSel || ordersStopLossSel==0)) {
      //TODO:更新止损值
      GlobalVariableSet(STOP_LOSS_LINE,Ask+Point*trailingStopLoss);
      ordersStopLossSel = Ask+Point*trailingStopLoss;
      CreatLine(STOP_LOSS_LINE,Ask+Point*trailingStopLoss,clrIndianRed);
   }

   //达到止损条件则止损:
   if(opType == OP_BUY)
   {
      if(Bid < ordersStopLossBuy && ordersStopLossBuy!=0 )
      {
         CloseAll(OP_BUY,comment,magic);
         GlobalVariableDel(STOP_LOSS_LINE);
         ObjectDelete(STOP_LOSS_LINE);
      }
   }
   if(opType == OP_SELL)
   {
      if(Ask > ordersStopLossSel && ordersStopLossSel!=0 )
      {
         CloseAll(OP_SELL,comment,magic);
         GlobalVariableDel(STOP_LOSS_LINE);
         ObjectDelete(STOP_LOSS_LINE);
      }
   }
   
   return retVal;
 }

//+------------------------------------------------------------------+
//| toEasystrategy3 function : 启动监控策略的实例进程
//|   int magic     : 魔术数 用于标识和管理实例
//|   返回值 : -1
//+------------------------------------------------------------------+
int toEasystrategy3(int magic)
 {
   double profit1_all=0,profit2_all=0;
   profit1_all = OrdersProfitBy(-1,"",magic_no);
   profit2_all = OrdersProfitBy(-1,"",trend_magic_no);
   double profit_all=profit1_all+profit2_all;
   double strategy3_risk_loss = AccountBalance()*strategy3_risk_value;

   if(gEAStart&&strategy3_enable&&checkClosingOrdersCnt(-1)<=0)
   {
      double martinLotsBuy = OrdersLotsBy(OP_BUY,"",magic_no);
      double martinLotsSel = OrdersLotsBy(OP_SELL,"",magic_no);
      double hedgeLotsBuy = OrdersLotsBy(OP_BUY,"",trend_magic_no);
      double hedgeLotsSel = OrdersLotsBy(OP_SELL,"",trend_magic_no);

      //TODO: 监控策略开仓
      if(profit_all<-strategy3_risk_loss)
      {
         double buyLotsAll = martinLotsBuy + hedgeLotsBuy;
         double selLotsAll = martinLotsSel + hedgeLotsSel;
         if(buyLotsAll>selLotsAll&&OrdersTotalBy(OP_SELL,"",magic)<=0&&strategy3SelCheck(magic))
            mySel(ND((buyLotsAll-selLotsAll)*strategy3_hedge_ratio,2),"TO-EASY-S3SEL",magic);
         if(selLotsAll>buyLotsAll&&OrdersTotalBy(OP_BUY,"",magic)<=0&&strategy3BuyCheck(magic))
            myBuy(ND((selLotsAll-buyLotsAll)*strategy3_hedge_ratio,2),"TO-EASY-S3BUY",magic);
      }
   }

   if(strategy3_enable&&checkClosingOrdersCnt(-1)<=0)
   {
      //TODO: 监控策略平仓
      if(profit_all>-strategy3_risk_loss)
      {
         int buyS3Total = OrdersTotalBy(OP_BUY,"",magic);
         if(buyS3Total>0&&strategy3CloseBuyCheck(magic))
            CloseAll(OP_BUY,"",magic);
         int selS3Total = OrdersTotalBy(OP_SELL,"",magic);
         if(selS3Total>0&&strategy3CloseSelCheck(magic))
            CloseAll(OP_SELL,"",magic);
      }
   }

   return -1;
 }

bool strategy3BuyCheck(int magic)
 {
   if(AC指标为负不做多&&(iAC(NULL,PERIOD_H1,0)<0))
      return false;

   double iCci0 = iCCI(NULL,PERIOD_D1,14,PRICE_CLOSE,0);
   if(iCci0>0)
      return true;

   return false;
 }
bool strategy3SelCheck(int magic)
 {
   if(AC指标为正不做空&&(iAC(NULL,PERIOD_H1,0)>0))
      return false;

   double iCci0 = iCCI(NULL,PERIOD_D1,14,PRICE_CLOSE,0);
   if(iCci0<0)
      return true;

   return false;
 }

bool strategy3CloseBuyCheck(int magic)
 {
   //if(AC指标为负不做多&&(iAC(NULL,PERIOD_M15,0)<0))
      //return false;

   double iCci0 = iCCI(NULL,PERIOD_M15,14,PRICE_CLOSE,0);
   if(iCci0<0)
      return true;

   return false;
 }
bool strategy3CloseSelCheck(int magic)
 {
   //if(AC指标为正不做空&&(iAC(NULL,PERIOD_M15,0)>0))
      //return false;

   double iCci0 = iCCI(NULL,PERIOD_M15,14,PRICE_CLOSE,0);
   if(iCci0>0)
      return true;

   return false;
 }

/* 
input int mm_mode = 2; //资金管理模式(0:无管理,1:只支持盈利目标模式,2:只支持总体亏损平仓,3:盈利目标模式和总体亏损平仓)
input int profit_period = 0; //盈利目标周期(0:天,1:周,2:月3:季,4:半年,5:年)
input int profit_target = 1000; //盈利目标金额
input int risk_mode = 1; //风险控制模式(0:浮亏止损,1:浮亏余额比例止损)
input double risk_value1 = 880;   //允许最大浮亏
input double risk_value2 = 0.0618; //风险系数(相对于余额)
*/
void money_manage(int magic1,int magic2,int magic3)
 {
   if(mm_mode==0)
      return;   
   double profit1_all=0,profit2_all=0,profit3_all=0;
   if(magic1>0) profit1_all = OrdersProfitBy(-1,"",magic1);
   if(magic2>0) profit2_all = OrdersProfitBy(-1,"",magic2);
   if(magic3>0) profit3_all = OrdersProfitBy(-1,"",magic3);
   double profit_all=profit1_all+profit2_all+profit3_all;
   
   if(mm_mode==1||mm_mode==3)
   {
      //TODO:支持盈利目标模式的处理
      
      if(mm_mode==1)
         return;
   }
   
   if(mm_mode==2||mm_mode==3)
   {
      double risk_stop_loss = 1000000;
      if(risk_mode==0)
         risk_stop_loss = risk_value1;
      else if(risk_mode==1)
         risk_stop_loss = AccountBalance()*risk_value2;
      else return;
      if(profit_all<-risk_stop_loss)
      {
         //TODO:风控止损
         if(magic1>0) CloseAll(-1,"",magic1);
         if(magic2>0) CloseAll(-1,"",magic2);
         if(magic3>0) CloseAll(-1,"",magic3);
      }
   }
 }

//+------------------------------------------------------------------+
//+-----------------------------------------------------------------+
//| Normalize Double                                                |
//+-----------------------------------------------------------------+
double ND(double Value,int Precision){return(NormalizeDouble(Value,Precision));}

//+-----------------------------------------------------------------+
//| Double To String                                                |
//+-----------------------------------------------------------------+
string DTS(double Value,int Precision){return(DoubleToStr(Value,Precision));}

 //以下是显示在图表上的内容    
      void bocun() {
   string bc_0 = "bocun_0";
   ObjectDelete(bc_0);
   ObjectCreate(bc_0, OBJ_LABEL, 0, 0, 0);
   ObjectSet(bc_0, OBJPROP_CORNER, 0);
   ObjectSet(bc_0, OBJPROP_XDISTANCE, 750);
   ObjectSet(bc_0, OBJPROP_YDISTANCE, 25);
   ObjectSetText(bc_0, "服务器时间:" + TimeToStr(TimeCurrent()) + "", 10, "Arial", clrDarkOrange);
   
   string bc_1 = "bocun_1";
   ObjectDelete(bc_1);
   ObjectCreate(bc_1, OBJ_LABEL, 0, 0, 0);
   ObjectSet(bc_1, OBJPROP_CORNER, 0);
   ObjectSet(bc_1, OBJPROP_XDISTANCE, 750);
   ObjectSet(bc_1, OBJPROP_YDISTANCE, 60);
   ObjectSetText(bc_1, "账面盈亏:" + DTS(AccountProfit(), 2) + "", 15, "Arial", clrDarkOrange);
   string bc_2 = "bocun_2";
   ObjectDelete(bc_2);
   ObjectCreate(bc_2, OBJ_LABEL, 0, 0, 0);
   ObjectSet(bc_2, OBJPROP_CORNER, 0);
   ObjectSet(bc_2, OBJPROP_XDISTANCE, 750);
   ObjectSet(bc_2, OBJPROP_YDISTANCE, 80);
   ObjectSetText(bc_2, "订单总量:" + DTS(OrdersTotal(),2) + "", 15, "Arial", clrDarkOrange);
  
   string bc_3 = "bocun_3";
   
   ObjectDelete(bc_3);
   ObjectCreate(bc_3, OBJ_LABEL, 0, 0, 0);
   ObjectSet(bc_3, OBJPROP_CORNER, 0);
   ObjectSet(bc_3, OBJPROP_XDISTANCE, 250);
   ObjectSet(bc_3, OBJPROP_YDISTANCE, 160);
   ObjectSetText(bc_3, "最新价格:" + DTS(Bid, Digits) + "", 35, "粗体", Red);
   string bc_4 = "bocun_4";
   ObjectDelete(bc_4);
   ObjectCreate(bc_4, OBJ_LABEL, 0, 0, 0);
   ObjectSet(bc_4, OBJPROP_CORNER, 0);
   ObjectSet(bc_4, OBJPROP_XDISTANCE, 750);
   ObjectSet(bc_4, OBJPROP_YDISTANCE,100);
   ObjectSetText(bc_4, "账面资金:" + DTS(AccountBalance(), 2) + "", 13, "Arial", clrDarkOrange);
   string bc_5 = "bocun_5";
   ObjectDelete(bc_5);
   ObjectCreate(bc_5, OBJ_LABEL, 0, 0, 0);
   ObjectSet(bc_5, OBJPROP_CORNER, 0);
   ObjectSet(bc_5, OBJPROP_XDISTANCE, 750);
   ObjectSet(bc_5, OBJPROP_YDISTANCE, 120);
   ObjectSetText(bc_5, "净值资金:" + DTS(AccountEquity(), 2) + "", 13, "Arial", clrDarkOrange);
   string bc_6 = "bocun_6";
   ObjectDelete(bc_6);
   ObjectCreate(bc_6, OBJ_LABEL, 0, 0, 0);
   ObjectSet(bc_6, OBJPROP_CORNER, 0);
   ObjectSet(bc_6, OBJPROP_XDISTANCE, 750);
   ObjectSet(bc_6, OBJPROP_YDISTANCE, 140);
   ObjectSetText(bc_6, "保证资金:" + DTS(AccountMargin(), 2) + "", 13, "Arial", clrDarkOrange);
   string bc_7 = "bocun_7";
   ObjectDelete(bc_7);
   ObjectCreate(bc_7, OBJ_LABEL, 0, 0, 0);
   ObjectSet(bc_7, OBJPROP_CORNER, 0);
   ObjectSet(bc_7, OBJPROP_XDISTANCE, 750);
   ObjectSet(bc_7, OBJPROP_YDISTANCE, 160);
   ObjectSetText(bc_7, "可用资金:" + DTS(AccountFreeMargin(), 2) + "", 13, "Arial", clrDarkOrange);
   string bc_16 = "bocun_16";
   ObjectDelete(bc_16);
   ObjectCreate(bc_16, OBJ_LABEL, 0, 0, 0);
   ObjectSet(bc_16, OBJPROP_CORNER, 0);
   ObjectSet(bc_16, OBJPROP_XDISTANCE, 750);
   ObjectSet(bc_16, OBJPROP_YDISTANCE, 180);
   ObjectSetText(bc_16, "最大跌幅(金额):" + DTS(DDBuffer, 2) , 13, "Arial", clrDarkOrange);
   string bc_17 = "bocun_17";
   ObjectDelete(bc_17);
   ObjectCreate(bc_17, OBJ_LABEL, 0, 0, 0);
   ObjectSet(bc_17, OBJPROP_CORNER, 0);
   ObjectSet(bc_17, OBJPROP_XDISTANCE, 750);
   ObjectSet(bc_17, OBJPROP_YDISTANCE, 200);
   ObjectSetText(bc_17, "最大跌幅(比例):" + DTS(DDBuffer_Percent, 1) + "%" , 13, "Arial", clrDarkOrange);
    string bc_33 = "bocun_33";
   string l_dbl2str_872 = "";
    double ld_944 = (Ask - Bid) / Point;
   l_dbl2str_872 = DTS(ld_944, Digits - 4);
   ObjectDelete(bc_33);
   ObjectCreate(bc_33, OBJ_LABEL, 0, 0, 0);
   ObjectSet(bc_33, OBJPROP_CORNER, 0);
   ObjectSet(bc_33, OBJPROP_XDISTANCE, 750);
   ObjectSet(bc_33, OBJPROP_YDISTANCE, 220);
   ObjectSetText(bc_33, "点差:" + l_dbl2str_872 + "", 13, "Arial", clrDarkOrange);
   
   string bc_32 = "bocun_32";
   string l_dbl2str_880 = "";
   double l_iopen_928 = iOpen(NULL, PERIOD_D1, 0);
   double l_iclose_936 = iClose(NULL, PERIOD_D1, 0);
   l_dbl2str_880 = DTS((l_iclose_936 - l_iopen_928) / Point, 0);
   ObjectDelete(bc_32);
   ObjectCreate(bc_32, OBJ_LABEL, 0, 0, 0);
   ObjectSet(bc_32, OBJPROP_CORNER, 0);
   ObjectSet(bc_32, OBJPROP_XDISTANCE, 750);
   ObjectSet(bc_32, OBJPROP_YDISTANCE, 240);
   ObjectSetText(bc_32, "波动率:" + l_dbl2str_880 + "", 13, "Arial", clrDarkOrange);
  }    
 void bocun1(){ 
 
 string bc_8 = "bocun_8";
   ObjectDelete(bc_8);
   ObjectCreate(bc_8, OBJ_LABEL, 0, 0, 0);
   ObjectSet(bc_8, OBJPROP_CORNER, 0);
   ObjectSet(bc_8, OBJPROP_XDISTANCE, 750);
   ObjectSet(bc_8, OBJPROP_YDISTANCE, 40);
   ObjectSetText(bc_8, "平台杠杆" +DTS(AccountLeverage(),2)+"：1", 15, "粗体", clrDarkOrange);
 string bc_9 = "bocun_9";
   ObjectDelete(bc_9);
   ObjectCreate(bc_9, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(bc_9, "网站："+txt+"", 13, "Arial", clrDarkOrange);
   ObjectSet(bc_9, OBJPROP_CORNER, 0);
   ObjectSet(bc_9, OBJPROP_XDISTANCE, 750);
   ObjectSet(bc_9, OBJPROP_YDISTANCE, 260);
    
 string bc_10="bocun_10";
   ObjectDelete(bc_10);
   ObjectCreate(bc_10, OBJ_LABEL, 0, 0, 0);
   ObjectSet(bc_10,OBJPROP_XDISTANCE,380);
   ObjectSet(bc_10,OBJPROP_YDISTANCE,16);
   ObjectSetText(bc_10,"TOEASY",35,"华文琥珀",clrMagenta);
   string bc_11="bocun_11";
   ObjectDelete(bc_11);
   ObjectCreate(bc_11, OBJ_LABEL, 0, 0, 0);
   ObjectSet(bc_11,OBJPROP_XDISTANCE,990);
   ObjectSet(bc_11,OBJPROP_YDISTANCE,400);
   ObjectSetText(bc_11,"////////////"+DTS(Year(),0)+"////////////",16,"华文琥珀",Crimson);
   string bc_12="bocun_12";
   ObjectDelete(bc_12);
   ObjectCreate(bc_12, OBJ_LABEL, 0, 0, 0);
   ObjectSet(bc_12,OBJPROP_XDISTANCE,990);
   ObjectSet(bc_12,OBJPROP_YDISTANCE,350);
   ObjectSetText(bc_12,"TOEASY",35,"Parchment",Crimson);
     string bc_13="bocun_13";
   ObjectDelete(bc_13);
   ObjectCreate(bc_13, OBJ_LABEL, 0, 0, 0);
   ObjectSet(bc_13,OBJPROP_XDISTANCE,68);
   ObjectSet(bc_13,OBJPROP_YDISTANCE,30);
   ObjectSetText(bc_13,"交易注释："+tc,10,"Tahoma",Crimson);

 }


void CreateButtons()
 {
   int x_dist=30,y_dist=20;
   bool button1 = CreateButton(0,"open_buy",0,x_dist+120,y_dist+30,64,25,CORNER_RIGHT_UPPER,"对冲做多","Arial",9,clrGreen,C'236,233,216',clrNONE,false,false,false,true,0);
   bool button2 = CreateButton(0,"open_sel",0,x_dist+ 50,y_dist+30,64,25,CORNER_RIGHT_UPPER,"对冲做空","Arial",9,clrGreen,C'236,233,216',clrNONE,false,false,false,true,0);
   bool button3 = CreateButton(0,"clse_buy",0,x_dist+120,y_dist+60,64,25,CORNER_RIGHT_UPPER,"平对冲多","Arial",9,clrRed  ,C'236,233,216',clrNONE,false,false,false,true,0);
   bool button4 = CreateButton(0,"clse_sel",0,x_dist+ 50,y_dist+60,64,25,CORNER_RIGHT_UPPER,"平对冲空","Arial",9,clrRed  ,C'236,233,216',clrNONE,false,false,false,true,0);
   bool button5 = CreateButton(0,"clse_all",0,x_dist+120,y_dist+90,64,26,CORNER_RIGHT_UPPER,"一键全平","Arial",9,clrRed  ,C'236,233,216',clrNONE,false,false,false,true,0);
   bool button6 = CreateButton(0,"renew_ea",0,x_dist+ 50,y_dist+90,64,25,CORNER_RIGHT_UPPER,"自动交易","Arial",9,clrRed  ,C'180,180,255',clrNONE,true ,false,false,true,0);
 }

void DeleteButtons()
 {
   DeleteButton(0,"open_buy");
   DeleteButton(0,"open_sel");
   DeleteButton(0,"clse_buy");
   DeleteButton(0,"clse_sel");
   DeleteButton(0,"clse_all");
   DeleteButton(0,"renew_ea");
 }

//+------------------------------------------------------------------+
//| 创建功能按钮                                                      |
//+------------------------------------------------------------------+
bool CreateButton(const long              chart_ID=0,               // chart's ID 
                  const string            name="Button",            // button name 
                  const int               sub_window=0,             // subwindow index 
                  const int               x=0,                      // X coordinate 
                  const int               y=0,                      // Y coordinate 
                  const int               width=100,                // button width 
                  const int               height=30,                // button height 
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                  const string            text="Button",            // text 
                  const string            font="Arial",             // font 
                  const int               font_size=10,             // font size 
                  const color             clr=clrBlack,             // text color 
                  const color             back_clr=C'236,233,216',  // background color 
                  const color             border_clr=clrNONE,       // border color 
                  const bool              state=false,              // pressed/released 
                  const bool              back=false,               // in the background 
                  const bool              selection=false,          // highlight to move 
                  const bool              hidden=true,              // hidden in the object list 
                  const long              z_order=0)                // priority for mouse click 
 {
 //--- reset the error value
   ResetLastError();
 //--- create the button
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
   {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());
      return(false);
   }
 //--- set button coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
 //--- set button size 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
 //--- set the chart's corner, relative to which point coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
 //--- set the text 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
 //--- set text font 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
 //--- set font size 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
 //--- set text color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
 //--- set background color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
 //--- set border color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
 //--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
 //--- set button state 
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
 //--- enable (true) or disable (false) the mode of moving the button by mouse 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
 //--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
 //--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
 //--- successful execution 
   return(true);
 }

//设置按钮按下状态
void SetButtonState(string name, bool state)
 {
   ObjectSetInteger(0,name,OBJPROP_STATE,state);
   ChartRedraw();
 }

//获得按迅按下状态
bool GetButtonState(string name)
 {
   return ObjectGetInteger(0,name,OBJPROP_STATE);
 }

//删除功能按钮
bool DeleteButton(const long   chart_ID=0,    // chart's ID 
                  const string name="Button") // button name 
 {
 //--- reset the error value 
   ResetLastError();
 //--- delete the button 
   if(!ObjectDelete(chart_ID,name))
   {
      Print(__FUNCTION__,
            ": failed to delete the button! Error code = ",GetLastError());
      return(false);
   }
 //--- successful execution 
   return(true);
 }

//修改按钮文字
bool ButtonTextChange(const long   chart_ID=0,    // chart's ID
                      const string name="Button", // button name
                      const string text="Text")   // text
 {
 //--- reset the error value 
   ResetLastError();
 //--- change object text 
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
   {
      Print(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
   }
 //--- successful execution 
   return(true);
 }


/*
input bool   martin_enable = true; //马丁开启
input double basic_lots = 0.01;  //基础手数
input int    basic_balance = 10000; //基础余额
input int    lots_mode =0;     //仓位模型(0:使用基础手数,1:根据余额复利)
*/
void ParaInit(bool saveFlag)
 {
   string fileName = Symbol()+"_conf.set";
   int handle = 0;
   if(saveFlag||FileIsExist(fileName)==false)
   {
      handle=FileOpen(fileName,FILE_READ|FILE_WRITE|FILE_TXT|FILE_SHARE_READ,",",CP_ACP);
      if(handle!=INVALID_HANDLE)
      {
         FileWrite(handle,"martin_enable="+(martin_enable?"true":"false"));
         FileWrite(handle,"basic_lots="+DoubleToStr(basic_lots,2));
         FileWrite(handle,"basic_balance="+IntegerToString(basic_balance));
         FileClose(handle);
      }
   }
   else
   {
      handle=FileOpen(fileName,FILE_READ|FILE_WRITE|FILE_TXT|FILE_SHARE_READ,",",CP_ACP);
      if(handle!=INVALID_HANDLE)
      {
         while(FileIsEnding(handle)!=True)
         {
            string read=FileReadString(handle);
            string sep="=";  // A separator as a character
            ushort u_sep;    // The code of the separator character
            string result[]; // An array to get strings
            //--- Get the separator code
            u_sep=StringGetCharacter(sep,0);
            //--- Split the string to substrings 
            int k=StringSplit(read,u_sep,result);
            //--- Now output all obtained strings 
            if(k==2) 
            {
               if(result[0]=="martin_enable")
                  martin_enable = (result[1]=="true"?true:false);
               if(result[0]=="basic_lots")
                  basic_lots = StringToDouble(result[1]);
               if(result[0]=="basic_balance")
                  basic_balance = (int)StringToInteger(result[1]);
            }
            //Comment(""+martin_enable+" "+basic_lots+" "+basic_balance);
         }
         FileClose(handle);
      }
   }
 }

