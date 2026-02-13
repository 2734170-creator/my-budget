/* Спринт 0.5: Схема БД и безопасность */
-- Включить RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE households ENABLE ROW LEVEL SECURITY;
ALTER TABLE household_members ENABLE ROW LEVEL SECURITY;
-- Политики для profiles
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
-- Политики для household_members
CREATE POLICY "Users can view own memberships" ON household_members FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can insert own membership" ON household_members FOR INSERT WITH CHECK (user_id = auth.uid());
-- Политики для households
CREATE POLICY "Members can view household" ON households FOR SELECT USING (
  id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid())
);
CREATE POLICY "Owners can create households" ON households FOR INSERT WITH CHECK (auth.uid() = created_by);
-- Функция триггера
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, avatar_url)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'avatar_url');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- Триггер
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
