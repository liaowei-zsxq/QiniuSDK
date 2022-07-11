//
//  QNTestConfig.h
//  QiniuSDK
//
//  Created by bailong on 14/10/7.
//  Copyright (c) 2014年 Qiniu. All rights reserved.
//
#import <Foundation/Foundation.h>
// 华东上传凭证
static NSString *const token_z0 = @"dxVQk8gyk3WswArbNhdKIwmwibJ9nFsQhMNUmtIM:9kdCQbapQPP2ZVD9WV7Ezf3_0aA=:eyJzY29wZSI6ImtvZG8tcGhvbmUtem9uZTAtc3BhY2UiLCJkZWFkbGluZSI6MTY2MjcxMDk4MiwgInJldHVybkJvZHkiOiJ7XCJjYWxsYmFja1VybFwiOlwiaHR0cDpcL1wvY2FsbGJhY2suZGV2LnFpbml1LmlvXCIsIFwiZm9vXCI6JCh4OmZvbyksIFwiYmFyXCI6JCh4OmJhciksIFwibWltZVR5cGVcIjokKG1pbWVUeXBlKSwgXCJoYXNoXCI6JChldGFnKSwgXCJrZXlcIjokKGtleSksIFwiZm5hbWVcIjokKGZuYW1lKX0ifQ==";
// 华北上传凭证
static NSString *const token_z1 = @"dxVQk8gyk3WswArbNhdKIwmwibJ9nFsQhMNUmtIM:B0fKOS32Meomwz5gVvkrM1RaaqY=:eyJzY29wZSI6ImtvZG8tcGhvbmUtem9uZTEtc3BhY2UiLCJkZWFkbGluZSI6MTY2MjcxMDk4MiwgInJldHVybkJvZHkiOiJ7XCJjYWxsYmFja1VybFwiOlwiaHR0cDpcL1wvY2FsbGJhY2suZGV2LnFpbml1LmlvXCIsIFwiZm9vXCI6JCh4OmZvbyksIFwiYmFyXCI6JCh4OmJhciksIFwibWltZVR5cGVcIjokKG1pbWVUeXBlKSwgXCJoYXNoXCI6JChldGFnKSwgXCJrZXlcIjokKGtleSksIFwiZm5hbWVcIjokKGZuYW1lKX0ifQ==";
// 华南上传凭证
static NSString *const token_z2 = @"dxVQk8gyk3WswArbNhdKIwmwibJ9nFsQhMNUmtIM:pSTXEJp7e2XUbQiwJ8dbzraYnec=:eyJzY29wZSI6ImtvZG8tcGhvbmUtem9uZTItc3BhY2UiLCJkZWFkbGluZSI6MTY2MjcxMDk4MiwgInJldHVybkJvZHkiOiJ7XCJjYWxsYmFja1VybFwiOlwiaHR0cDpcL1wvY2FsbGJhY2suZGV2LnFpbml1LmlvXCIsIFwiZm9vXCI6JCh4OmZvbyksIFwiYmFyXCI6JCh4OmJhciksIFwibWltZVR5cGVcIjokKG1pbWVUeXBlKSwgXCJoYXNoXCI6JChldGFnKSwgXCJrZXlcIjokKGtleSksIFwiZm5hbWVcIjokKGZuYW1lKX0ifQ==";
// 北美上传凭证
static NSString *const token_na0 = @"dxVQk8gyk3WswArbNhdKIwmwibJ9nFsQhMNUmtIM:sw_-B84hrqGpo0PWfZSogIM6Sis=:eyJzY29wZSI6ImtvZG8tcGhvbmUtem9uZS1uYTAtc3BhY2UiLCJkZWFkbGluZSI6MTY2MjcxMDk4MiwgInJldHVybkJvZHkiOiJ7XCJjYWxsYmFja1VybFwiOlwiaHR0cDpcL1wvY2FsbGJhY2suZGV2LnFpbml1LmlvXCIsIFwiZm9vXCI6JCh4OmZvbyksIFwiYmFyXCI6JCh4OmJhciksIFwibWltZVR5cGVcIjokKG1pbWVUeXBlKSwgXCJoYXNoXCI6JChldGFnKSwgXCJrZXlcIjokKGtleSksIFwiZm5hbWVcIjokKGZuYW1lKX0ifQ==";
// 东南亚上传凭证
static NSString *const token_as0 = @"dxVQk8gyk3WswArbNhdKIwmwibJ9nFsQhMNUmtIM:_QQcTsikr_HDK1gugztImhkIebI=:eyJzY29wZSI6ImtvZG8tcGhvbmUtem9uZS1hczAtc3BhY2UiLCJkZWFkbGluZSI6MTY2MjcxMDk4MiwgInJldHVybkJvZHkiOiJ7XCJjYWxsYmFja1VybFwiOlwiaHR0cDpcL1wvY2FsbGJhY2suZGV2LnFpbml1LmlvXCIsIFwiZm9vXCI6JCh4OmZvbyksIFwiYmFyXCI6JCh4OmJhciksIFwibWltZVR5cGVcIjokKG1pbWVUeXBlKSwgXCJoYXNoXCI6JChldGFnKSwgXCJrZXlcIjokKGtleSksIFwiZm5hbWVcIjokKGZuYW1lKX0ifQ==";
// 雾存储华东一区
static NSString *const token_fog_cn_east1 = @"dxVQk8gyk3WswArbNhdKIwmwibJ9nFsQhMNUmtIM:FBTItCc_WXYaFmUn1vCsnmrfS7w=:eyJzY29wZSI6InRlc3QtZm9nLWNuLWVhc3QtMSIsImRlYWRsaW5lIjoxNjYyNzEwOTgyLCAicmV0dXJuQm9keSI6IntcImNhbGxiYWNrVXJsXCI6XCJodHRwOlwvXC9jYWxsYmFjay5kZXYucWluaXUuaW9cIiwgXCJmb29cIjokKHg6Zm9vKSwgXCJiYXJcIjokKHg6YmFyKSwgXCJtaW1lVHlwZVwiOiQobWltZVR5cGUpLCBcImhhc2hcIjokKGV0YWcpLCBcImtleVwiOiQoa2V5KSwgXCJmbmFtZVwiOiQoZm5hbWUpfSJ9";
