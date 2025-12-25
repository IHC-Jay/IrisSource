public class X12Transactions
{
    public class transMap
    {
        public string? Name { get; set; }
        public string? Rule { get; set; } = null;
    };

    public static transMap[] TransactionsArr = new transMap[]
    {
        new transMap
        {
            Name = "270",
            Rule = "Rules_5010_270_005010X279A1.Rules"
        },
        new transMap
        {
            Name = "271",
            Rule = "Rules_5010_271_005010X279A1.Rules"
        },
        new transMap
        {
            Name = "276",
            Rule = "Rules_5010_276_005010X212.Rules"
        },
        new transMap
        {
            Name = "277",
            Rule = "Rules_5010_277_005010X212.Rules"
        },
        new transMap
        {
            Name = "277CA",
            Rule = "Rules_5010_277CA_005010X214.Rules"
        },
        new transMap
        {
            Name = "999",
            Rule = "Rules_5010_999_005010X231A1.Rules"
        },
        new transMap
        {
            Name = "835",
            Rule = "Rules_5010_835_005010X221A1.Rules"
        },
        new transMap
        {
            Name = "837P",
            Rule = "Rules_5010_837P_005010X222A1.Rules"
        },
        new transMap
        {
            Name = "837I",
            Rule = "Rules_5010_837I_005010X223A2.Rules"
        },
        new transMap
        {
            Name = "837D",
            Rule = "Rules_5010_837D_005010X224A2.Rules"
        }
    };
}